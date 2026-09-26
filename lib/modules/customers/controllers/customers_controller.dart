import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_searchable_dropdown_field.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../data/models/company_dropdown.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/franchise_dropdown.dart';
import '../../../data/models/get_all_customers_request.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../routes/app_routes.dart';

class CustomersController extends GetxController {
  CustomersController({
    required this.customerRepository,
    required this.franchiseRepository,
  });

  final CustomerRepository customerRepository;
  final FranchiseRepository franchiseRepository;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingCompanies = false.obs;
  final RxBool isLoadingFranchises = false.obs;
  final RxBool isDeleting = false.obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<CompanyDropdownItem> companyOptions =
      <CompanyDropdownItem>[].obs;
  final RxList<FranchiseDropdownItem> franchiseOptions =
      <FranchiseDropdownItem>[].obs;
  final RxnInt selectedCompanyId = RxnInt();
  final RxnInt selectedFranchiseId = RxnInt();
  final RxString searchQuery = ''.obs;
  final RxnInt selectedCustomerId = RxnInt();

  final searchController = TextEditingController();

  int get companyCode => selectedCompanyId.value ?? 0;
  int get franchiseCode => selectedFranchiseId.value ?? 0;

  String get selectedCompanyLabel {
    final id = selectedCompanyId.value;
    if (id == null) return '';
    for (final item in companyOptions) {
      if (item.id == id) return item.value;
    }
    return 'Company #$id';
  }

  String get selectedFranchiseLabel {
    final id = selectedFranchiseId.value;
    if (id == null) return '';
    for (final item in franchiseOptions) {
      if (item.franchiseCode == id) return item.franchiseName;
    }
    return 'Franchise #$id';
  }

  List<AppSearchableDropdownItem<int>> get companyDropdownItems =>
      companyOptions
          .map(
            (c) => AppSearchableDropdownItem(value: c.id, label: c.value),
          )
          .toList();

  List<AppSearchableDropdownItem<int>> get franchiseDropdownItems =>
      franchiseOptions
          .map(
            (f) => AppSearchableDropdownItem(
              value: f.franchiseCode,
              label: f.franchiseName,
            ),
          )
          .toList();

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
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

  Future<List<AppSearchableDropdownItem<int>>> loadCompanies({
    bool force = false,
  }) async {
    if (isClosed) return companyDropdownItems;
    if (isLoadingCompanies.value && !force) return companyDropdownItems;
    isLoadingCompanies.value = true;
    try {
      final response = await franchiseRepository.getCompanyDropdown();
      if (isClosed) return const [];
      companyOptions.assignAll(response.items);
      return companyDropdownItems;
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
      return companyDropdownItems;
    } finally {
      if (!isClosed) isLoadingCompanies.value = false;
    }
  }

  Future<void> onCompanySelected(int? id) async {
    if (isClosed || id == null) return;
    if (selectedCompanyId.value == id) return;

    selectedCompanyId.value = id;
    selectedFranchiseId.value = null;
    franchiseOptions.clear();
    customers.clear();
    selectedCustomerId.value = null;

    await loadFranchisesForCompany(id);
  }

  Future<List<AppSearchableDropdownItem<int>>> loadFranchisesForCompany(
    int companyId, {
    bool force = false,
  }) async {
    if (isClosed) return franchiseDropdownItems;
    if (isLoadingFranchises.value && !force) return franchiseDropdownItems;
    isLoadingFranchises.value = true;
    try {
      final response =
          await franchiseRepository.getFranchiseDropdown(companyId);
      if (isClosed) return const [];
      franchiseOptions.assignAll(
        response.items
            .where((f) => f.franchiseCode > 0)
            .toList(),
      );
      return franchiseDropdownItems;
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
      return franchiseDropdownItems;
    } finally {
      if (!isClosed) isLoadingFranchises.value = false;
    }
  }

  Future<List<AppSearchableDropdownItem<int>>> loadFranchisesSheet() async {
    final companyId = selectedCompanyId.value;
    if (companyId == null) return const [];
    return loadFranchisesForCompany(companyId);
  }

  Future<void> onFranchiseSelected(int? id) async {
    if (isClosed || id == null) return;
    if (selectedFranchiseId.value == id) return;
    selectedFranchiseId.value = id;
    selectedCustomerId.value = null;
    await loadCustomers(force: true);
  }

  Future<void> loadCustomers({bool force = false}) async {
    if (isClosed || (isLoading.value && !force)) return;

    final companyId = selectedCompanyId.value;
    final franchiseId = selectedFranchiseId.value;
    if (companyId == null || franchiseId == null) {
      customers.clear();
      return;
    }

    isLoading.value = true;
    try {
      final response = await customerRepository.getAllCustomers(
        GetAllCustomersRequest(
          companyCode: companyId,
          franchiseCode: franchiseId,
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
      } else if (customers.isEmpty) {
        selectedCustomerId.value = null;
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
      if (result == true) loadCustomers(force: true);
    });
  }

  void openCustomerDetails(Customer customer) {
    selectCustomer(customer);
    Get.toNamed(
      Routes.customerDetails,
      arguments: customer.customerId,
    )?.then((_) {
      if (!isClosed) loadCustomers(force: true);
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
      if (result == true) loadCustomers(force: true);
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
