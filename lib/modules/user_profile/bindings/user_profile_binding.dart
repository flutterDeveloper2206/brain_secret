import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../data/repositories/user_repo_impl.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserRepository>()) {
      Get.put<UserRepository>(
        UserRepositoryImpl(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }
    Get.put<UserProfileController>(
      UserProfileController(
        userRepository: Get.find<UserRepository>(),
        permissionService: Get.find<PermissionService>(),
      ),
    );
  }
}
