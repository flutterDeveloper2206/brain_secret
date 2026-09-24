import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/customer_repo_impl.dart';
import '../controllers/customers_controller.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(
        () => CustomerRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    // fenix: recreate only when needed; avoids dispose mid-rebuild.
    Get.lazyPut<CustomersController>(
      () => CustomersController(
        customerRepository: Get.find<CustomerRepository>(),
      ),
      fenix: true,
    );
  }
}
