import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/permission_master_repo.dart';
import '../../../data/repositories/permission_master_repo_impl.dart';
import '../../../data/repositories/role_master_repo.dart';
import '../../../data/repositories/role_master_repo_impl.dart';
import '../controllers/role_permission_mapping_controller.dart';

class RolePermissionMappingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RoleMasterRepository>()) {
      Get.lazyPut<RoleMasterRepository>(
        () => RoleMasterRepositoryImpl(
          apiService: Get.find<ApiService>(),
        ),
      );
    }
    if (!Get.isRegistered<PermissionMasterRepository>()) {
      Get.lazyPut<PermissionMasterRepository>(
        () => PermissionMasterRepositoryImpl(
          apiService: Get.find<ApiService>(),
        ),
      );
    }
    Get.lazyPut<RolePermissionMappingController>(
      () => RolePermissionMappingController(
        roleRepository: Get.find<RoleMasterRepository>(),
        permissionRepository: Get.find<PermissionMasterRepository>(),
      ),
      fenix: true,
    );
  }
}
