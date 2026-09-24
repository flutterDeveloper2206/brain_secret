import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../data/repositories/franchise_repo_impl.dart';
import '../controllers/franchise_profile_controller.dart';

class FranchiseProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FranchiseRepository>()) {
      Get.lazyPut<FranchiseRepository>(
        () => FranchiseRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.put<FranchiseProfileController>(
      FranchiseProfileController(
        franchiseRepository: Get.find<FranchiseRepository>(),
      ),
    );
  }
}
