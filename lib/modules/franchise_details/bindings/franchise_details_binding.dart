import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../data/repositories/franchise_repo_impl.dart';
import '../controllers/franchise_details_controller.dart';

class FranchiseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FranchiseRepository>()) {
      Get.lazyPut<FranchiseRepository>(
        () => FranchiseRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.put<FranchiseDetailsController>(
      FranchiseDetailsController(
        franchiseRepository: Get.find<FranchiseRepository>(),
      ),
    );
  }
}
