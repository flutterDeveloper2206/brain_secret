import 'package:get/get.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/company_dropdown.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/entity_picker_result.dart';
import '../../../data/models/franchise_dropdown.dart';
import '../../../data/models/get_all_customers_request.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/franchise_repo.dart';

enum EntityPickerStep { company, franchise, customer, family }

class EntityPickerController extends GetxController {
  EntityPickerController({
    required this.franchiseRepository,
    required this.customerRepository,
  });

  final FranchiseRepository franchiseRepository;
  final CustomerRepository customerRepository;

  final Rx<EntityPickerStep> step = EntityPickerStep.company.obs;
  final RxBool isLoading = false.obs;

  final RxList<CompanyDropdownItem> companies = <CompanyDropdownItem>[].obs;
  final RxList<FranchiseDropdownItem> franchises =
      <FranchiseDropdownItem>[].obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<CompanyDropdownItem> familyMembers =
      <CompanyDropdownItem>[].obs;

  final RxnInt selectedCompanyId = RxnInt();
  final RxnInt selectedFranchiseId = RxnInt();
  final RxnInt selectedCustomerId = RxnInt();
  final RxnInt selectedFamilyId = RxnInt();

  static const stepLabels = ['Company', 'Franchise', 'Customer', 'Family'];

  int get stepIndex => EntityPickerStep.values.indexOf(step.value);
  bool get isFirstStep => step.value == EntityPickerStep.company;
  bool get isLastStep => step.value == EntityPickerStep.family;

  String get stepTitle => stepLabels[stepIndex];

  String get selectedCompanyName {
    final id = selectedCompanyId.value;
    if (id == null) return '';
    for (final c in companies) {
      if (c.id == id) return c.value;
    }
    return 'Company #$id';
  }

  String get selectedFranchiseName {
    final id = selectedFranchiseId.value;
    if (id == null) return '';
    for (final f in franchises) {
      if (f.franchiseCode == id) return f.franchiseName;
    }
    return 'Franchise #$id';
  }

  String get selectedCustomerName {
    final id = selectedCustomerId.value;
    if (id == null) return '';
    for (final c in customers) {
      if (c.customerId == id) return c.customerFullName;
    }
    return 'Customer #$id';
  }

  String get selectedFamilyName {
    final id = selectedFamilyId.value;
    if (id == null) return '';
    for (final f in familyMembers) {
      if (f.id == id) return f.value;
    }
    return 'Family #$id';
  }

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    isLoading.value = true;
    try {
      final response = await franchiseRepository.getCompanyDropdown();
      companies.assignAll(response.items);
      selectedCompanyId.value =
          companies.isEmpty ? null : companies.first.id;
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> loadFranchises() async {
    final companyId = selectedCompanyId.value;
    if (companyId == null) {
      GlassSnackbar.warning('Please select a company', title: 'Missing');
      return;
    }

    isLoading.value = true;
    try {
      final response =
          await franchiseRepository.getFranchiseDropdown(companyId);
      franchises.assignAll(response.items);
      selectedFranchiseId.value =
          franchises.isEmpty ? null : franchises.first.franchiseCode;
      customers.clear();
      familyMembers.clear();
      selectedCustomerId.value = null;
      selectedFamilyId.value = null;
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> loadCustomers() async {
    final companyId = selectedCompanyId.value;
    final franchiseId = selectedFranchiseId.value;
    if (companyId == null || franchiseId == null) {
      GlassSnackbar.warning(
        'Please select company and franchise',
        title: 'Missing',
      );
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
      customers.assignAll(response.customers);
      selectedCustomerId.value =
          customers.isEmpty ? null : customers.first.customerId;
      familyMembers.clear();
      selectedFamilyId.value = null;
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> loadFamily() async {
    final customerId = selectedCustomerId.value;
    if (customerId == null) {
      GlassSnackbar.warning('Please select a customer', title: 'Missing');
      return;
    }

    isLoading.value = true;
    try {
      final items = await customerRepository.getCustomersFamily(customerId);
      familyMembers.assignAll(items);
      selectedFamilyId.value =
          familyMembers.isEmpty ? null : familyMembers.first.id;
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void selectCompany(int id) {
    selectedCompanyId.value = id;
    selectedCompanyId.refresh();
  }

  void selectFranchise(int id) {
    selectedFranchiseId.value = id;
    selectedFranchiseId.refresh();
  }

  void selectCustomer(int id) {
    selectedCustomerId.value = id;
    selectedCustomerId.refresh();
  }

  void selectFamily(int id) {
    selectedFamilyId.value = id;
    selectedFamilyId.refresh();
  }

  Future<void> goNext() async {
    if (isLoading.value) return;

    switch (step.value) {
      case EntityPickerStep.company:
        if (selectedCompanyId.value == null) {
          GlassSnackbar.warning('Please select a company', title: 'Missing');
          return;
        }
        await loadFranchises();
        if (isClosed) return;
        step.value = EntityPickerStep.franchise;
        break;
      case EntityPickerStep.franchise:
        if (selectedFranchiseId.value == null) {
          GlassSnackbar.warning('Please select a franchise', title: 'Missing');
          return;
        }
        await loadCustomers();
        if (isClosed) return;
        step.value = EntityPickerStep.customer;
        break;
      case EntityPickerStep.customer:
        if (selectedCustomerId.value == null) {
          GlassSnackbar.warning('Please select a customer', title: 'Missing');
          return;
        }
        await loadFamily();
        if (isClosed) return;
        step.value = EntityPickerStep.family;
        break;
      case EntityPickerStep.family:
        confirmSelection();
        break;
    }
  }

  void goPrevious() {
    if (isFirstStep || isLoading.value) return;
    switch (step.value) {
      case EntityPickerStep.franchise:
        step.value = EntityPickerStep.company;
        break;
      case EntityPickerStep.customer:
        step.value = EntityPickerStep.franchise;
        break;
      case EntityPickerStep.family:
        step.value = EntityPickerStep.customer;
        break;
      case EntityPickerStep.company:
        break;
    }
  }

  void confirmSelection() {
    final companyId = selectedCompanyId.value;
    final franchiseId = selectedFranchiseId.value;
    final customerId = selectedCustomerId.value;
    final familyId = selectedFamilyId.value;

    if (companyId == null ||
        franchiseId == null ||
        customerId == null ||
        familyId == null) {
      GlassSnackbar.warning(
        'Please complete all selections',
        title: 'Incomplete',
      );
      return;
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.back(
      result: EntityPickerResult(
        companyId: companyId,
        companyName: selectedCompanyName,
        franchiseId: franchiseId,
        franchiseName: selectedFranchiseName,
        customerId: customerId,
        customerName: selectedCustomerName,
        familyId: familyId,
        familyName: selectedFamilyName,
      ),
    );
  }
}
