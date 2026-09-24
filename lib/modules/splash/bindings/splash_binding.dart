import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/permissions_repo.dart';
import '../../../data/repositories/permissions_repo_impl.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PermissionsRepository>()) {
      Get.put<PermissionsRepository>(
        PermissionsRepositoryImpl(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    Get.put<SplashController>(
      SplashController(
        apiService: Get.find<ApiService>(),
        permissionService: Get.find<PermissionService>(),
        permissionsRepository: Get.find<PermissionsRepository>(),
      ),
    );
  }
}
