import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/customer_repo_impl.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../data/repositories/franchise_repo_impl.dart';
import '../controllers/customer_profile_controller.dart';

class CustomerProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(
        () => CustomerRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    if (!Get.isRegistered<FranchiseRepository>()) {
      Get.lazyPut<FranchiseRepository>(
        () => FranchiseRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    // Always recreate so edit/create args are applied in onInit.
    if (Get.isRegistered<CustomerProfileController>()) {
      Get.delete<CustomerProfileController>(force: true);
    }
    Get.put<CustomerProfileController>(
      CustomerProfileController(
        customerRepository: Get.find<CustomerRepository>(),
        franchiseRepository: Get.find<FranchiseRepository>(),
      ),
    );
  }
}
