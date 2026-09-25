import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/permission_master_repo.dart';
import '../../../data/repositories/permission_master_repo_impl.dart';
import '../controllers/permission_action_mapping_controller.dart';

class PermissionActionMappingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PermissionMasterRepository>()) {
      Get.lazyPut<PermissionMasterRepository>(
        () => PermissionMasterRepositoryImpl(
          apiService: Get.find<ApiService>(),
        ),
      );
    }
    Get.lazyPut<PermissionActionMappingController>(
      () => PermissionActionMappingController(
        repository: Get.find<PermissionMasterRepository>(),
      ),
      fenix: true,
    );
  }
}
