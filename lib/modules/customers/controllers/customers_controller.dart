import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/get_all_customers_request.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../routes/app_routes.dart';

class CustomersController extends GetxController {
  CustomersController({required this.customerRepository});

  final CustomerRepository customerRepository;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnInt selectedCustomerId = RxnInt();

  final searchController = TextEditingController();

  int companyCode = 1;
  int franchiseCode = 1;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  List<Customer> get filteredCustomers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return customers.toList();
    return customers.where((customer) {
      final haystack = [
        customer.customerFullName,
        customer.mobileNo,
        customer.emailId,
        customer.cityName,
        customer.organization,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Customer? get selectedCustomer {
    final id = selectedCustomerId.value;
    if (id == null) return null;
    for (final customer in customers) {
      if (customer.customerId == id) return customer;
    }
    return null;
  }

  void onSearchChanged(String value) {
    if (isClosed) return;
    searchQuery.value = value;
  }

  void clearSearch() {
    if (isClosed) return;
    searchController.clear();
    searchQuery.value = '';
  }

  void selectCustomer(Customer customer) {
    if (isClosed) return;
    selectedCustomerId.value = customer.customerId;
  }

  Future<void> loadCustomers() async {
    if (isClosed || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await customerRepository.getAllCustomers(
        GetAllCustomersRequest(
          companyCode: companyCode,
          franchiseCode: franchiseCode,
        ),
      );
      if (isClosed) return;
      customers.assignAll(response.customers);
      final selected = selectedCustomerId.value;
      if (selected != null &&
          customers.every((c) => c.customerId != selected)) {
        selectedCustomerId.value =
            customers.isEmpty ? null : customers.first.customerId;
      } else if (selected == null && customers.isNotEmpty) {
        selectedCustomerId.value = customers.first.customerId;
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void openCreateCustomer() {
    Get.toNamed(Routes.customerProfile)?.then((result) {
      if (isClosed) return;
      if (result == true) loadCustomers();
    });
  }

  void openCustomerDetails(Customer customer) {
    selectCustomer(customer);
    Get.toNamed(
      Routes.customerDetails,
      arguments: customer.customerId,
    )?.then((_) {
      if (!isClosed) loadCustomers();
    });
  }

  void openEditSelected() {
    final customer = selectedCustomer;
    if (customer == null) return;
    Get.toNamed(
      Routes.customerProfile,
      arguments: {
        'customerId': customer.customerId,
        'customer': customer,
      },
    )?.then((result) {
      if (isClosed) return;
      if (result == true) loadCustomers();
    });
  }

  Future<void> confirmDelete(Customer customer) async {
    if (isClosed || isDeleting.value) return;
    final confirmed = await GlassPopup.confirm(
      title: 'Delete Customer',
      message:
          'Delete ${customer.customerFullName.isEmpty ? 'this customer' : customer.customerFullName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || isClosed) return;

    isDeleting.value = true;
    try {
      final response = await customerRepository.deleteCustomer(
        customer.customerId,
      );
      if (isClosed) return;
      customers.removeWhere((c) => c.customerId == customer.customerId);
      if (selectedCustomerId.value == customer.customerId) {
        selectedCustomerId.value =
            customers.isEmpty ? null : customers.first.customerId;
      }
      ErrorHandler.showSuccess(
        response.message.isEmpty
            ? 'Customer deleted successfully.'
            : response.message,
        title: 'Deleted',
      );
    } catch (e) {
      if (isClosed) return;
      ErrorHandler.handleError(
        e,
        onNotFound: () {
          customers.removeWhere((c) => c.customerId == customer.customerId);
          if (selectedCustomerId.value == customer.customerId) {
            selectedCustomerId.value =
                customers.isEmpty ? null : customers.first.customerId;
          }
        },
      );
    } finally {
      if (!isClosed) isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
