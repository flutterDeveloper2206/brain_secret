import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../data/repositories/franchise_repo_impl.dart';
import '../controllers/franchises_controller.dart';

class FranchisesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FranchiseRepository>()) {
      Get.lazyPut<FranchiseRepository>(
        () => FranchiseRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.lazyPut<FranchisesController>(
      () => FranchisesController(
        franchiseRepository: Get.find<FranchiseRepository>(),
      ),
      fenix: true,
    );
  }
}
