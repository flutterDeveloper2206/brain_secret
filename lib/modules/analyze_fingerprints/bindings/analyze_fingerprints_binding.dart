import 'package:get/get.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../controllers/analyze_fingerprints_controller.dart';

class AnalyzeFingerprintsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalyzeFingerprintsController>(
      () => AnalyzeFingerprintsController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
  }
}
