package com.example.finger_print_scan

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.os.Message
import com.futronictech.Scanner
import com.futronictech.UsbDeviceDataExchangeImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import kotlin.math.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.finger_print_scan/ridge_counting"
    private val STREAM_CHANNEL = "com.example.finger_print_scan/live_stream"
    private var usbHostCtx: UsbDeviceDataExchangeImpl? = null
    private var pendingScanResult: MethodChannel.Result? = null

    private var eventSink: EventChannel.EventSink? = null
    private var isStreaming = false
    private var lastCapturedFrame: ByteArray? = null
    private var liveScanArgs: Map<String, Boolean>? = null

    private val usbHandler = object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                UsbDeviceDataExchangeImpl.MESSAGE_ALLOW_DEVICE -> {
                    if (usbHostCtx?.ValidateContext() == true) {
                        if (isStreaming) {
                            startDeviceLiveScan()
                        } else {
                            startDeviceScan()
                        }
                    } else {
                        pendingScanResult?.error("DEVICE_CONTEXT_INVALID", "Failed to validate context after approval", null)
                        pendingScanResult = null
                        isStreaming = false
                    }
                }
                UsbDeviceDataExchangeImpl.MESSAGE_DENY_DEVICE -> {
                    pendingScanResult?.error("USB_PERMISSION_DENIED", "User denied USB scanner permission", null)
                    pendingScanResult = null
                    isStreaming = false
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        if (!OpenCVLoader.initDebug()) {
            // Handle initialization error
        }

        usbHostCtx = UsbDeviceDataExchangeImpl(this, usbHandler)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    isStreaming = false
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "countRidges" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val coreX = call.argument<Double>("coreX") ?: 0.0
                    val coreY = call.argument<Double>("coreY") ?: 0.0
                    val endX = call.argument<Double>("endX") ?: 0.0
                    val endY = call.argument<Double>("endY") ?: 0.0

                    if (imagePath != null) {
                        val count = countFingerprintRidges(imagePath, coreX, coreY, endX, endY)
                        result.success(count)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null", null)
                    }
                }
                "processImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath != null) {
                        val processedBytes = getProcessedImage(imagePath)
                        if (processedBytes != null) {
                            result.success(processedBytes)
                        } else {
                            result.error("PROCESSING_FAILED", "Failed to process image", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null", null)
                    }
                }
                "scanFingerprint" -> {
                    val mockBytes = generateDynamicMockFingerprint()
                    result.success(mockBytes)
                }
                "scanFingerprintDevice" -> {
                    pendingScanResult = result
                    val opened = usbHostCtx?.OpenDevice(0, true) ?: false
                    if (opened) {
                        startDeviceScan()
                    } else {
                        val pending = usbHostCtx?.IsPendingOpen() ?: false
                        if (!pending) {
                            result.error("DEVICE_OPEN_FAILED", "Failed to open scanner (not connected or interface error)", null)
                            pendingScanResult = null
                        }
                    }
                }
                "startLiveScan" -> {
                    val isFrame = call.argument<Boolean>("isFrame") ?: true
                    val isLfd = call.argument<Boolean>("isLfd") ?: false
                    val isInvert = call.argument<Boolean>("isInvert") ?: false
                    val isNfiq = call.argument<Boolean>("isNfiq") ?: false
                    val isUsbHost = call.argument<Boolean>("isUsbHost") ?: true

                    liveScanArgs = mapOf(
                        "isFrame" to isFrame,
                        "isLfd" to isLfd,
                        "isInvert" to isInvert,
                        "isNfiq" to isNfiq,
                        "isUsbHost" to isUsbHost
                    )

                    pendingScanResult = result
                    isStreaming = true

                    if (isUsbHost) {
                        val opened = usbHostCtx?.OpenDevice(0, true) ?: false
                        if (opened) {
                            startDeviceLiveScan()
                        } else {
                            val pending = usbHostCtx?.IsPendingOpen() ?: false
                            if (!pending) {
                                result.error("DEVICE_OPEN_FAILED", "Failed to open scanner (not connected or interface error)", null)
                                pendingScanResult = null
                                isStreaming = false
                            }
                        }
                    } else {
                        // Emulator fallback, return success instantly
                        result.success(true)
                    }
                }
                "stopLiveScan" -> {
                    isStreaming = false
                    Handler(Looper.getMainLooper()).postDelayed({
                        result.success(lastCapturedFrame)
                    }, 200)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startDeviceScan() {
        val result = pendingScanResult
        if (result == null) return
        pendingScanResult = null

        Thread {
            try {
                val devScan = Scanner()
                val syncDir = getExternalFilesDir(null)
                if (syncDir != null) {
                    devScan.SetGlobalSyncDir(syncDir.toString())
                }

                if (!devScan.OpenDeviceOnInterfaceUsbHost(usbHostCtx)) {
                    val errMsg = devScan.GetErrorMessage()
                    runOnUiThread {
                        result.error("SCANNER_OPEN_FAILED", "Failed to open device interface: $errMsg", null)
                    }
                    return@Thread
                }

                if (!devScan.GetImageSize()) {
                    val errMsg = devScan.GetErrorMessage()
                    devScan.CloseDeviceUsbHost()
                    runOnUiThread {
                        result.error("GET_SIZE_FAILED", "Failed to read image dimensions: $errMsg", null)
                    }
                    return@Thread
                }

                // Explicitly configure scanner options: disable LFD (Live Finger Detection) and disable inverting image.
                val mask = devScan.FTR_OPTIONS_DETECT_FAKE_FINGER or devScan.FTR_OPTIONS_INVERT_IMAGE
                devScan.SetOptions(mask, 0)

                val w = devScan.GetImageWidth()
                val h = devScan.GetImaegHeight()
                val frameData = ByteArray(w * h)

                var captureSuccess = false
                val startTime = System.currentTimeMillis()
                val timeoutMs = 20000L // 20 seconds timeout

                while (System.currentTimeMillis() - startTime < timeoutMs) {
                    // Use GetImage2 (with dose level 4) which is the standard capture function for Futronic scanners.
                    captureSuccess = devScan.GetImage2(4, frameData)
                    if (captureSuccess) {
                        break
                    }

                    val errCode = devScan.GetErrorCode()
                    val errMsg = devScan.GetErrorMessage() ?: ""
                    android.util.Log.d("FUTRONIC", "GetImage2 failed: Code=$errCode, Msg=$errMsg")

                    val isTransientError = errMsg.contains("Empty Frame", ignoreCase = true) ||
                                           errMsg.contains("Movable Finger", ignoreCase = true) ||
                                           errMsg.contains("No Frame", ignoreCase = true) ||
                                           errCode == devScan.FTR_ERROR_EMPTY_FRAME ||
                                           errCode == devScan.FTR_ERROR_MOVABLE_FINGER ||
                                           errCode == devScan.FTR_ERROR_NO_FRAME

                    if (!isTransientError) {
                        // If it's a fatal hardware error (e.g. device disconnected), stop polling immediately
                        android.util.Log.e("FUTRONIC", "Fatal error encountered, stopping polling: $errMsg")
                        break
                    }

                    // Wait 100ms before polling again to prevent high CPU utilization
                    Thread.sleep(100)
                }

                devScan.CloseDeviceUsbHost()

                if (!captureSuccess) {
                    val errMsg = devScan.GetErrorMessage()
                    runOnUiThread {
                        result.error("CAPTURE_FAILED", "Failed to capture fingerprint frame: $errMsg", null)
                    }
                    return@Thread
                }

                // Convert raw frame bytes to standard ARGB PNG Bitmap
                val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                val pixels = IntArray(w * h)
                for (i in frameData.indices) {
                    val grey = frameData[i].toInt() and 0xFF
                    pixels[i] = (0xFF shl 24) or (grey shl 16) or (grey shl 8) or grey
                }
                bitmap.setPixels(pixels, 0, w, 0, 0, w, h)

                val bos = java.io.ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos)
                val imageBytes = bos.toByteArray()

                runOnUiThread {
                    result.success(imageBytes)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    result.error("SCAN_EXCEPTION", e.message ?: "Unknown scanning error", null)
                }
            }
        }.start()
    }

    private fun startDeviceLiveScan() {
        val result = pendingScanResult
        if (result == null) return
        pendingScanResult = null

        // Return immediately to confirm stream startup
        result.success(true)

        Thread {
            try {
                val args = liveScanArgs
                val isFrame = args?.get("isFrame") ?: true
                val isLfd = args?.get("isLfd") ?: false
                val isInvert = args?.get("isInvert") ?: false
                val isNfiq = args?.get("isNfiq") ?: false

                val devScan = Scanner()
                val syncDir = getExternalFilesDir(null)
                if (syncDir != null) {
                    devScan.SetGlobalSyncDir(syncDir.toString())
                }

                if (!devScan.OpenDeviceOnInterfaceUsbHost(usbHostCtx)) {
                    val errMsg = devScan.GetErrorMessage()
                    runOnUiThread {
                        eventSink?.error("SCANNER_OPEN_FAILED", "Failed to open device interface: $errMsg", null)
                    }
                    return@Thread
                }

                if (!devScan.GetImageSize()) {
                    val errMsg = devScan.GetErrorMessage()
                    devScan.CloseDeviceUsbHost()
                    runOnUiThread {
                        eventSink?.error("GET_SIZE_FAILED", "Failed to read image dimensions: $errMsg", null)
                    }
                    return@Thread
                }

                val w = devScan.GetImageWidth()
                val h = devScan.GetImaegHeight()
                val frameData = ByteArray(w * h)

                // Set options
                val mask = devScan.FTR_OPTIONS_DETECT_FAKE_FINGER or devScan.FTR_OPTIONS_INVERT_IMAGE
                var flag = 0
                if (isLfd) flag = flag or devScan.FTR_OPTIONS_DETECT_FAKE_FINGER
                if (isInvert) flag = flag or devScan.FTR_OPTIONS_INVERT_IMAGE
                devScan.SetOptions(mask, flag)

                while (isStreaming) {
                    val captureSuccess = if (isFrame) {
                        devScan.GetFrame(frameData)
                    } else {
                        devScan.GetImage2(4, frameData)
                    }

                    val errCode = devScan.GetErrorCode()
                    val errMsg = devScan.GetErrorMessage() ?: ""

                    if (captureSuccess) {
                        // Calculate NFIQ if requested
                        var nfiqValue = 0
                        if (isNfiq) {
                            if (devScan.GetNfiqFromImage(frameData, w, h)) {
                                nfiqValue = devScan.GetNIFQValue()
                            }
                        }

                        // Convert to standard PNG
                        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                        val pixels = IntArray(w * h)
                        for (i in frameData.indices) {
                            val grey = frameData[i].toInt() and 0xFF
                            pixels[i] = (0xFF shl 24) or (grey shl 16) or (grey shl 8) or grey
                        }
                        bitmap.setPixels(pixels, 0, w, 0, 0, w, h)

                        val bos = java.io.ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos)
                        val imageBytes = bos.toByteArray()
                        
                        // Save last captured frame
                        lastCapturedFrame = imageBytes

                        runOnUiThread {
                            val event = HashMap<String, Any>()
                            event["image"] = imageBytes
                            event["nfiq"] = nfiqValue
                            event["status"] = "OK"
                            eventSink?.success(event)
                        }
                    } else {
                        runOnUiThread {
                            val event = HashMap<String, Any>()
                            event["status"] = errMsg
                            event["errCode"] = errCode
                            eventSink?.success(event)
                        }
                    }

                    // Polling rate throttling
                    Thread.sleep(100)
                }

                devScan.CloseDeviceUsbHost()
            } catch (e: Exception) {
                runOnUiThread {
                    eventSink?.error("LIVE_SCAN_EXCEPTION", e.message ?: "Unknown scanning error", null)
                }
            }
        }.start()
    }

    private fun generateDynamicMockFingerprint(): ByteArray {
        val width = 300
        val height = 400
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bitmap)
        
        // Background: White
        canvas.drawColor(android.graphics.Color.WHITE)
        
        val paint = android.graphics.Paint().apply {
            color = android.graphics.Color.BLACK
            style = android.graphics.Paint.Style.STROKE
            strokeWidth = 3.5f
            isAntiAlias = true
        }
        
        val centerX = width / 2f
        val centerY = height * 0.55f
        
        // Draw concentric loops
        for (r in 15..250 step 12) {
            val radiusX = r.toFloat()
            val radiusY = r * 1.3f
            val rectF = android.graphics.RectF(
                centerX - radiusX, 
                centerY - radiusY, 
                centerX + radiusX, 
                centerY + radiusY
            )
            canvas.drawOval(rectF, paint)
        }
        
        val stream = java.io.ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun getProcessedImage(path: String): ByteArray? {
        val src = BitmapFactory.decodeFile(path) ?: return null
        val mat = Mat()
        org.opencv.android.Utils.bitmapToMat(src, mat)

        // Process to get clean white ridges on black background
        val processed = preprocess(mat)
        
        // Invert to show BLACK RIDGES on WHITE BACKGROUND (like the original photo)
        val inverted = Mat()
        Core.bitwise_not(processed, inverted)
        
        // Dilate the black ridges slightly if needed, but let's keep them clean first
        // As seen in original photos, standard forensic prints are black-on-white.
        
        // Convert processed Mat back to Bitmap
        val resultBitmap = Bitmap.createBitmap(inverted.cols(), inverted.rows(), Bitmap.Config.ARGB_8888)
        org.opencv.android.Utils.matToBitmap(inverted, resultBitmap)
        
        val stream = java.io.ByteArrayOutputStream()
        resultBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun preprocess(mat: Mat): Mat {
        // 1. Grayscale
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_RGB2GRAY)

        // 2. Bilateral Filter - Superior for smoothing while keeping ridge edges sharp
        val smoothed = Mat()
        Imgproc.bilateralFilter(gray, smoothed, 1, 30.0, 30.0)

        // 3. High-Contrast Enrichment using CLAHE
        // Clip limit of 6.0 for very bold ridges
        val clahe = Imgproc.createCLAHE(1.0, Size(8.0, 8.0))
        val enhanced = Mat()
        clahe.apply(smoothed, enhanced)

        // 4. Adaptive Thresholding - Capturing ALL black linings
        val binary = Mat()
        Imgproc.adaptiveThreshold(
            enhanced, binary, 255.0,
            Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
            Imgproc.THRESH_BINARY_INV, 51, 6.0 // Lower C (6.0) is more inclusive of all lines
        )

        // 5. Morphological Smoothing and Gap Closing
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, Size(3.0, 3.0))
        
        // Closing: Bridges tiny gaps in ridges for "proper lining"
        Imgproc.morphologyEx(binary, binary, Imgproc.MORPH_CLOSE, kernel)
        
        // 6. Professional Smoothing
        // Median Blur (radius 3) preserves more detail than radius 5
        Imgproc.medianBlur(binary, binary, 3)

        // 7. Connected Components Filtering (Balanced)
        val labels = Mat()
        val stats = Mat()
        val centroids = Mat()
        val numLabels = Imgproc.connectedComponentsWithStats(binary, labels, stats, centroids)
        
        val cleaned = Mat.zeros(binary.size(), CvType.CV_8UC1)
        for (i in 1 until numLabels) {
            val area = stats.get(i, Imgproc.CC_STAT_AREA)[0]
            val width = stats.get(i, Imgproc.CC_STAT_WIDTH)[0]
            val height = stats.get(i, Imgproc.CC_STAT_HEIGHT)[0]
            
            // Lower threshold (150) captures ALL valid ridge parts
            if (area > 150 || (width > 20 || height > 20)) {
                val mask = Mat()
                Core.compare(labels, Scalar(i.toDouble()), mask, Core.CMP_EQ)
                Core.bitwise_or(cleaned, mask, cleaned)
            }
        }
        
        return cleaned
    }

    private fun countFingerprintRidges(path: String, x1: Double, y1: Double, x2: Double, y2: Double): Int {
        val src = BitmapFactory.decodeFile(path) ?: return 0
        val mat = Mat()
        org.opencv.android.Utils.bitmapToMat(src, mat)

        val cleaned = preprocess(mat)

        // precise thinning
        val skeleton = skeletonize(cleaned)

        return countIntersections(skeleton, x1, y1, x2, y2)
    }

    private fun skeletonize(input: Mat): Mat {
        val skel = Mat.zeros(input.size(), CvType.CV_8UC1)
        val temp = Mat()
        val eroded = Mat()
        val element = Imgproc.getStructuringElement(Imgproc.MORPH_CROSS, Size(3.0, 3.0))
        var done = false

        val copy = input.clone()

        while (!done) {
            Imgproc.erode(copy, eroded, element)
            Imgproc.dilate(eroded, temp, element)
            Core.subtract(copy, temp, temp)
            Core.bitwise_or(skel, temp, skel)
            eroded.copyTo(copy)

            if (Core.countNonZero(copy) == 0) done = true
        }
        return skel
    }

       private fun countIntersections(skel: Mat, x1: Double, y1: Double, x2: Double, y2: Double): Int {
        var count = 0
        
        val dx = x2 - x1
        val dy = y2 - y1
        val length = sqrt(dx * dx + dy * dy)
        if (length < 2.0) return 0
        
        // High density sampling (0.2px) for accurate crossing detection
        val steps = (length * 5).toInt()
        var ridgeState = false 
        var ridgePixels = 0
        
        // Skip only the first 3 pixels (around the core point)
        val skipSteps = (5 / (length / steps)).toInt().coerceAtMost(steps / 4)

        for (i in 0 until steps) {
            val t = i.toDouble() / steps
            val px = (x1 + t * dx).toInt()
            val py = (y1 + t * dy).toInt()
            
            if (px < 0 || px >= skel.cols() || py < 0 || py >= skel.rows()) continue
            
            val value = skel.get(py, px)[0].toInt()
            val isRidge = value > 127
            
            if (i > skipSteps) {
                if (isRidge && !ridgeState) {
                    ridgeState = true
                    ridgePixels = 1
                } else if (isRidge && ridgeState) {
                    ridgePixels++
                } else if (!isRidge && ridgeState) {
                    // With 0.2px sampling, a 1px skeleton line is ~5 sequential samples.
                    // Counting anything >= 3 samples avoids single-point noise.
                    if (ridgePixels >= 3) { 
                        count++
                    }
                    ridgeState = false
                    ridgePixels = 0
                }
            }
        }
        
        if (ridgeState && ridgePixels >= 3) {
            count++
        }
        
        return count
    }

}
