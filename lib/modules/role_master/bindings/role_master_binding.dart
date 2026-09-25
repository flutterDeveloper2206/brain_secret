import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/role_master_repo.dart';
import '../../../data/repositories/role_master_repo_impl.dart';
import '../controllers/role_master_controller.dart';

class RoleMasterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RoleMasterRepository>()) {
      Get.lazyPut<RoleMasterRepository>(
        () => RoleMasterRepositoryImpl(
          apiService: Get.find<ApiService>(),
        ),
      );
    }
    Get.lazyPut<RoleMasterController>(
      () => RoleMasterController(
        repository: Get.find<RoleMasterRepository>(),
      ),
      fenix: true,
    );
  }
}
