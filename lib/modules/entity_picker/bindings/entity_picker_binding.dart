import 'package:get/get.dart';

import '../../../data/providers/api_service.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/customer_repo_impl.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../data/repositories/franchise_repo_impl.dart';
import '../controllers/entity_picker_controller.dart';

class EntityPickerBinding extends Bindings {
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
    Get.lazyPut<EntityPickerController>(
      () => EntityPickerController(
        franchiseRepository: Get.find<FranchiseRepository>(),
        customerRepository: Get.find<CustomerRepository>(),
      ),
    );
  }
}
