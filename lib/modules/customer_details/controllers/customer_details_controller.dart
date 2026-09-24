import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../routes/app_routes.dart';

class CustomerDetailsController extends GetxController {
  CustomerDetailsController({required this.customerRepository});

  final CustomerRepository customerRepository;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final Rxn<Customer> customer = Rxn<Customer>();

  late final int customerId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      customerId = args;
    } else if (args is Customer) {
      customerId = args.customerId;
      customer.value = args;
    } else {
      customerId = int.tryParse(args?.toString() ?? '') ?? 0;
    }
    loadDetails();
  }

  Future<void> loadDetails() async {
    if (customerId <= 0) {
      ErrorHandler.handleError(ServerException('Invalid customer id.'));
      return;
    }

    isLoading.value = true;
    try {
      final response = await customerRepository.getCustomer(customerId);
      customer.value = response.customer;
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isLoading.value = false;
    }
  }

  void openEdit() {
    final current = customer.value;
    if (current == null && customerId <= 0) return;
    Get.toNamed(
      Routes.customerProfile,
      arguments: {
        'customerId': current?.customerId ?? customerId,
        if (current != null) 'customer': current,
      },
    )?.then((result) {
      if (result == true) {
        loadDetails();
      }
    });
  }

  Future<void> confirmDelete() async {
    final current = customer.value;
    if (current == null || isDeleting.value) return;

    final confirmed = await GlassPopup.confirm(
      title: 'Delete Customer',
      message:
          'Delete ${current.customerFullName.isEmpty ? 'this customer' : current.customerFullName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    isDeleting.value = true;
    try {
      final response = await customerRepository.deleteCustomer(
        current.customerId,
      );
      // Pop before the snackbar, otherwise Get.back() closes the snackbar route.
      Get.back(result: true);
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        GlassSnackbar.success(
          response.message.isEmpty
              ? 'Customer deleted successfully.'
              : response.message,
          title: 'Deleted',
        );
      });
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isDeleting.value = false;
    }
  }
}
