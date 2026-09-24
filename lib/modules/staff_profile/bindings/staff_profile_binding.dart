import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../data/repositories/staff_repo_impl.dart';
import '../controllers/staff_profile_controller.dart';

class StaffProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut<StaffRepository>(
        () => StaffRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    if (Get.isRegistered<StaffProfileController>()) {
      Get.delete<StaffProfileController>(force: true);
    }
    Get.put<StaffProfileController>(
      StaffProfileController(staffRepository: Get.find<StaffRepository>()),
    );
  }
}
