import 'package:get/get.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../controllers/device_scan_controller.dart';

class DeviceScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceScanController>(
      () => DeviceScanController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
  }
}
