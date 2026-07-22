import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
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
  final RxString statusText = "Ready to Scan".obs;
  final RxInt nfiqScore = 0.obs;
  final Rxn<Uint8List> liveImageBytes = Rxn<Uint8List>();
  
  // List to hold up to 3 captured scans for the current finger
  final RxList<Uint8List> capturedScans = <Uint8List>[].obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    fingerCode = args?['fingerCode'] as String? ?? 'Unknown';
    _updateStatusMessage();
  }

  void _updateStatusMessage() {
    if (capturedScans.length < 3) {
      statusText.value = "Finger $fingerCode: Captured ${capturedScans.length}/3 scans. Tap 'Scan' to start.";
    } else {
      statusText.value = "Finger $fingerCode: 3/3 scans captured successfully! Tap 'Save' to return.";
    }
  }

  Future<void> startScan() async {
    if (isScanning.value) return;
    if (capturedScans.length >= 3) {
      Get.snackbar("Completed", "You have already captured 3 scans for this finger. Clear or save to proceed.");
      return;
    }

    try {
      isScanning.value = true;
      statusText.value = "Initializing scan for capture #${capturedScans.length + 1}...";
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

  void saveScan() {
    if (capturedScans.length < 3) {
      Get.snackbar(
        "Incomplete",
        "Please capture exactly 3 scans for $fingerCode before saving.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final handSelector = Get.find<HandSelectorController>();
      handSelector.saveFingerScans(fingerCode, capturedScans.toList());
      
      Get.back();
      Get.snackbar(
        "Finger Scanned",
        "Successfully registered 3 scans for $fingerCode",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
