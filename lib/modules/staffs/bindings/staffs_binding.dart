import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../data/repositories/staff_repo_impl.dart';
import '../controllers/staffs_controller.dart';

class StaffsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut<StaffRepository>(
        () => StaffRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.lazyPut<StaffsController>(
      () => StaffsController(staffRepository: Get.find<StaffRepository>()),
      fenix: true,
    );
  }
}
