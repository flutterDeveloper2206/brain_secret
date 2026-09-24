import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../data/repositories/staff_repo_impl.dart';
import '../controllers/staff_details_controller.dart';

class StaffDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut<StaffRepository>(
        () => StaffRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.put<StaffDetailsController>(
      StaffDetailsController(staffRepository: Get.find<StaffRepository>()),
    );
  }
}
