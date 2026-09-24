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
    Get.lazyPut<NativeService>(() => NativeService());

    // Repository
    Get.lazyPut<FingerprintRepository>(
      () => FingerprintRepositoryImpl(
        nativeService: Get.find<NativeService>(),
        apiService: Get.find<ApiService>(),
      ),
    );

    // Controller
    Get.lazyPut<HomeController>(
      () => HomeController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
  }
}
