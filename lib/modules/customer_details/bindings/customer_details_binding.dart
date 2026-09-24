import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/customer_repo_impl.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(
        () => CustomerRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.put<CustomerDetailsController>(
      CustomerDetailsController(
        customerRepository: Get.find<CustomerRepository>(),
      ),
    );
  }
}
