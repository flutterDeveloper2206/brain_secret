import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/native_service.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../../../data/repositories/fingerprint_repo_impl.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse shared ApiService from app startup when available.
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<NativeService>()) {
      Get.put<NativeService>(NativeService(), permanent: true);
    }
    if (!Get.isRegistered<FingerprintRepository>()) {
      Get.put<FingerprintRepository>(
        FingerprintRepositoryImpl(
          nativeService: Get.find<NativeService>(),
          apiService: Get.find<ApiService>(),
        ),
        permanent: true,
      );
    }

    // Controller
    Get.lazyPut<HomeController>(
      () => HomeController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
  }
}
