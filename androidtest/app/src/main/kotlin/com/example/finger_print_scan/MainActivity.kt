package com.example.finger_print_scan

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import kotlin.math.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.finger_print_scan/ridge_counting"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        if (!OpenCVLoader.initDebug()) {
            // Handle initialization error
        }

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
                else -> result.notImplemented()
            }
        }
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
