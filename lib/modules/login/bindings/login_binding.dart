import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/auth_repo_impl.dart';
import '../../../data/repositories/permissions_repo.dart';
import '../../../data/repositories/permissions_repo_impl.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<PermissionsRepository>()) {
      Get.put<PermissionsRepository>(
        PermissionsRepositoryImpl(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepositoryImpl(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }
    Get.lazyPut<LoginController>(
      () => LoginController(
        authRepository: Get.find<AuthRepository>(),
        permissionsRepository: Get.find<PermissionsRepository>(),
        permissionService: Get.find<PermissionService>(),
        apiService: Get.find<ApiService>(),
      ),
    );
  }
}
