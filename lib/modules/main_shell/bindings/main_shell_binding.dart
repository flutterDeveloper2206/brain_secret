import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/native_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/auth_repo_impl.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../../../data/repositories/fingerprint_repo_impl.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/main_shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepositoryImpl(apiService: Get.find<ApiService>()),
        permanent: true,
      );
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
    Get.lazyPut<HomeController>(
      () => HomeController(
        repository: Get.find<FingerprintRepository>(),
      ),
    );
    Get.lazyPut<MainShellController>(
      () => MainShellController(
        authRepository: Get.find<AuthRepository>(),
        permissionService: Get.find<PermissionService>(),
        apiService: Get.find<ApiService>(),
      ),
    );
  }
}
