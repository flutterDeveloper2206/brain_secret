import 'package:get/get.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../controllers/analysis_controller.dart';

class AnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalysisController>(
      () => AnalysisController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
  }
}
