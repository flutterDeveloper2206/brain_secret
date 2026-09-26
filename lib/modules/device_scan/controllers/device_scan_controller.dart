import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../../hand_selector/controllers/hand_selector_controller.dart';

class DeviceScanController extends GetxController {
  final FingerprintRepository repository;

  DeviceScanController({required this.repository});

  // Target finger details
  late final String fingerCode;

  // Checkbox settings
  final RxBool isFrame = true.obs;
  final RxBool isLfd = false.obs;
  final RxBool isInvert = false.obs;
  final RxBool isNfiq = false.obs;
  final RxBool isUsbHost = true.obs;

  // Scan states
  final RxBool isScanning = false.obs;
  final RxBool isSaving = false.obs;
  final RxString statusText = "Ready to Scan".obs;
  final RxInt nfiqScore = 0.obs;
  final Rxn<Uint8List> liveImageBytes = Rxn<Uint8List>();

  // List to hold up to 3 captured scans for the current finger
  final RxList<Uint8List> capturedScans = <Uint8List>[].obs;

  StreamSubscription? _subscription;

  /// Minimal valid 1x1 JPEG for testing upload without a scanner.
  static final Uint8List _dummyJpeg = Uint8List.fromList(<int>[
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
    0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
    0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
    0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
    0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
    0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
    0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
    0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
    0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
    0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03,
    0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D,
    0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06,
    0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08,
    0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72,
    0x82, 0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28,
    0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45,
    0x46, 0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
    0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75,
    0x76, 0x77, 0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
    0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3,
    0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6,
    0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
    0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2,
    0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xF1, 0xF2, 0xF3, 0xF4,
    0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01,
    0x00, 0x00, 0x3F, 0x00, 0x7B, 0xDF, 0xFF, 0xD9,
  ]);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    fingerCode = args?['fingerCode'] as String? ?? 'Unknown';
    _updateStatusMessage();
  }

  void _updateStatusMessage() {
    if (capturedScans.length < 3) {
      statusText.value =
          "Finger $fingerCode: Captured ${capturedScans.length}/3 scans. Tap 'Scan' or tap an empty pass to add a dummy image.";
    } else {
      statusText.value =
          "Finger $fingerCode: 3/3 scans captured successfully! Tap 'Save' to upload.";
    }
  }

  /// Tap empty pass slot to fill a dummy image for API testing without hardware.
  void fillDummyScan(int index) {
    if (isScanning.value || isSaving.value) return;
    if (index < 0 || index > 2) return;
    if (capturedScans.length > index) return;

    while (capturedScans.length < index) {
      capturedScans.add(Uint8List.fromList(_dummyJpeg));
    }
    if (capturedScans.length == index) {
      capturedScans.add(Uint8List.fromList(_dummyJpeg));
    }
    liveImageBytes.value = capturedScans.last;
    _updateStatusMessage();
  }

  Future<void> startScan() async {
    if (isScanning.value) return;
    if (capturedScans.length >= 3) {
      Get.snackbar(
        "Completed",
        "You have already captured 3 scans for this finger. Clear or save to proceed.",
      );
      return;
    }

    try {
      isScanning.value = true;
      statusText.value =
          "Initializing scan for capture #${capturedScans.length + 1}...";
      nfiqScore.value = 0;

      final success = await repository.startLiveScan(
        isFrame: isFrame.value,
        isLfd: isLfd.value,
        isInvert: isInvert.value,
        isNfiq: isNfiq.value,
        isUsbHost: isUsbHost.value,
      );

      if (success) {
        statusText.value = "Place your finger on the device scanner...";
        _subscription = repository.liveScanStream.listen(
          (event) {
            final status = event['status'] as String? ?? '';
            if (status == 'OK') {
              final bytes = event['image'] as Uint8List?;
              if (bytes != null) {
                liveImageBytes.value = bytes;
              }
              nfiqScore.value = event['nfiq'] as int? ?? 0;
              statusText.value = isNfiq.value
                  ? "Scan active. Quality NFIQ: ${nfiqScore.value}"
                  : "Scanning... Adjust position.";
            } else {
              statusText.value = "Status: $status";
            }
          },
          onError: (e) {
            ErrorHandler.handleError(e);
            stopScan();
          },
          cancelOnError: true,
        );
      } else {
        isScanning.value = false;
        statusText.value = "Failed to start scanner interface.";
      }
    } catch (e) {
      isScanning.value = false;
      statusText.value = "Error starting scan: $e";
      ErrorHandler.handleError(e);
    }
  }

  Future<void> stopScan() async {
    if (!isScanning.value) return;

    statusText.value = "Capturing scan frame...";
    isScanning.value = false;

    try {
      await _subscription?.cancel();
      _subscription = null;

      final capturedBytes = await repository.stopLiveScan();
      if (capturedBytes != null) {
        liveImageBytes.value = capturedBytes;
        capturedScans.add(capturedBytes);
        statusText.value = "Capture #${capturedScans.length} complete.";
        _updateStatusMessage();
      } else {
        statusText.value = "Scan stopped. No frame captured.";
      }
    } catch (e) {
      statusText.value = "Error stopping scan: $e";
      ErrorHandler.handleError(e);
    }
  }

  void clearScans() {
    capturedScans.clear();
    liveImageBytes.value = null;
    nfiqScore.value = 0;
    _updateStatusMessage();
  }

  Future<void> saveScan() async {
    if (isSaving.value) return;
    if (capturedScans.length < 3) {
      Get.snackbar(
        "Incomplete",
        "Please capture exactly 3 scans for $fingerCode before saving.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    statusText.value = "Uploading fingerprint images...";
    try {
      await repository.addCustomerFingerprint(
        l2r: capturedScans[0],
        l2l: capturedScans[1],
        l2c: capturedScans[2],
        fingerName: fingerCode,
      );

      if (Get.isRegistered<HandSelectorController>()) {
        Get.find<HandSelectorController>().saveFingerScans(
          fingerCode,
          capturedScans.toList(),
        );
      }

      Get.back();
      GlassSnackbar.success(
        'Fingerprint uploaded for $fingerCode',
        title: 'Saved',
      );
    } catch (e) {
      statusText.value = "Upload failed. Try again.";
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
