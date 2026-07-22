import 'dart:typed_data';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class HandSelectorController extends GetxController {
  // Map of fingerCode -> List of 3 scan byte arrays
  final RxMap<String, List<Uint8List>> scannedFingers = <String, List<Uint8List>>{}.obs;
  
  // Currently selected finger (e.g., 'L1', 'L2', etc.)
  final RxnString selectedFinger = RxnString();

  void selectFinger(String fingerCode) {
    if (selectedFinger.value == fingerCode) {
      // Toggle off if clicked again
      selectedFinger.value = null;
    } else {
      selectedFinger.value = fingerCode;
    }
  }

  bool isFingerScanned(String fingerCode) {
    return scannedFingers.containsKey(fingerCode) && scannedFingers[fingerCode]!.length == 3;
  }

  void saveFingerScans(String fingerCode, List<Uint8List> scans) {
    scannedFingers[fingerCode] = scans;
    selectedFinger.value = null; // Clear selection after saving
  }

  void startScanning() {
    final finger = selectedFinger.value;
    if (finger != null) {
      Get.toNamed(
        Routes.deviceScan,
        arguments: {'fingerCode': finger},
      );
    }
  }

  String getFingerName(String code) {
    final isLeft = code.startsWith('L');
    final num = code.substring(1);
    final fingerNames = {
      '1': 'Thumb',
      '2': 'Index Finger',
      '3': 'Middle Finger',
      '4': 'Ring Finger',
      '5': 'Pinky Finger',
    };
    final name = fingerNames[num] ?? 'Finger';
    return "${isLeft ? 'Left' : 'Right'} $name ($code)";
  }
}
