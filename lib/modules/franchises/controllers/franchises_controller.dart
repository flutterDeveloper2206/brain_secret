import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_searchable_dropdown_field.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../data/models/company_dropdown.dart';
import '../../../data/models/franchise.dart';
import '../../../data/models/get_all_franchises_request.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../routes/app_routes.dart';

class FranchisesController extends GetxController {
  FranchisesController({required this.franchiseRepository});

  final FranchiseRepository franchiseRepository;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingCompanies = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isToggling = false.obs;
  final RxList<Franchise> franchises = <Franchise>[].obs;
  final RxList<CompanyDropdownItem> companyOptions =
      <CompanyDropdownItem>[].obs;
  final RxnInt selectedCompanyId = RxnInt(1);
  final RxString searchQuery = ''.obs;
  final RxnInt selectedFranchiseCode = RxnInt();

  final searchController = TextEditingController();

  int get companyCode => selectedCompanyId.value ?? 1;

  String get selectedCompanyLabel {
    final id = selectedCompanyId.value;
    if (id == null) return '';
    for (final item in companyOptions) {
      if (item.id == id) return item.value;
    }
    return 'Company #$id';
  }

  List<AppSearchableDropdownItem<int>> get companyDropdownItems =>
      companyOptions
          .map(
            (c) => AppSearchableDropdownItem(value: c.id, label: c.value),
          )
          .toList();

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
    loadFranchises();
  }

  List<Franchise> get filteredFranchises {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return franchises.toList();
    return franchises.where((franchise) {
      final haystack = [
        franchise.franchiseName,
        franchise.ownerName,
        franchise.mobileNo,
        franchise.emailId,
        franchise.city,
        franchise.gstNumber,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Franchise? get selectedFranchise {
    final code = selectedFranchiseCode.value;
    if (code == null) return null;
    for (final franchise in franchises) {
      if (franchise.franchiseCode == code) return franchise;
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

  void selectFranchise(Franchise franchise) {
    if (isClosed) return;
    selectedFranchiseCode.value = franchise.franchiseCode;
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
      if (selectedCompanyId.value == null && companyOptions.isNotEmpty) {
        selectedCompanyId.value = companyOptions.first.id;
      } else if (selectedCompanyId.value != null &&
          companyOptions.isNotEmpty &&
          companyOptions.every((c) => c.id != selectedCompanyId.value)) {
        selectedCompanyId.value = companyOptions.first.id;
      }
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
    selectedFranchiseCode.value = null;
    await loadFranchises(force: true);
  }

  Future<void> loadFranchises({bool force = false}) async {
    if (isClosed || (isLoading.value && !force)) return;
    isLoading.value = true;
    try {
      final response = await franchiseRepository.getAllFranchises(
        GetAllFranchisesRequest(companyCode: companyCode),
      );
      if (isClosed) return;
      franchises.assignAll(response.franchises);
      final selected = selectedFranchiseCode.value;
      if (selected != null &&
          franchises.every((f) => f.franchiseCode != selected)) {
        selectedFranchiseCode.value =
            franchises.isEmpty ? null : franchises.first.franchiseCode;
      } else if (selected == null && franchises.isNotEmpty) {
        selectedFranchiseCode.value = franchises.first.franchiseCode;
      } else if (franchises.isEmpty) {
        selectedFranchiseCode.value = null;
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void openCreateFranchise() {
    Get.toNamed(Routes.franchiseProfile)?.then((result) {
      if (isClosed) return;
      if (result == true) loadFranchises(force: true);
    });
  }

  void openFranchiseDetails(Franchise franchise) {
    selectFranchise(franchise);
    Get.toNamed(
      Routes.franchiseDetails,
      arguments: franchise.franchiseCode,
    )?.then((result) async {
      if (isClosed) return;
      if (result == true) {
        franchises.removeWhere(
          (f) => f.franchiseCode == franchise.franchiseCode,
        );
        if (selectedFranchiseCode.value == franchise.franchiseCode) {
          selectedFranchiseCode.value =
              franchises.isEmpty ? null : franchises.first.franchiseCode;
        }
      }
      await loadFranchises(force: true);
    });
  }

  void openEditSelected() {
    final franchise = selectedFranchise;
    if (franchise == null) return;
    Get.toNamed(
      Routes.franchiseProfile,
      arguments: {'franchiseCode': franchise.franchiseCode},
    )?.then((result) {
      if (isClosed) return;
      if (result == true) loadFranchises(force: true);
    });
  }

  Future<void> toggleActive(Franchise franchise) async {
    if (isClosed || isToggling.value) return;
    final nextLabel = franchise.isActive ? 'Inactive' : 'Active';
    final confirmed = await GlassPopup.confirm(
      title: 'Change Status',
      message:
          'Mark ${franchise.franchiseName.isEmpty ? 'this franchise' : franchise.franchiseName} as $nextLabel?',
      confirmText: 'Confirm',
    );
    if (!confirmed || isClosed) return;

    isToggling.value = true;
    try {
      final response = await franchiseRepository.toggleFranchiseActive(
        franchise.franchiseCode,
      );
      if (isClosed) return;
      await loadFranchises(force: true);
      ErrorHandler.showSuccess(
        response.message.isEmpty
            ? 'Franchise status updated successfully.'
            : response.message,
        title: 'Status Updated',
      );
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isToggling.value = false;
    }
  }

  Future<void> confirmDelete(Franchise franchise) async {
    if (isClosed || isDeleting.value) return;
    final confirmed = await GlassPopup.confirm(
      title: 'Delete Franchise',
      message:
          'Delete ${franchise.franchiseName.isEmpty ? 'this franchise' : franchise.franchiseName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || isClosed) return;

    isDeleting.value = true;
    try {
      final response = await franchiseRepository.softDeleteFranchise(
        franchise.franchiseCode,
      );
      if (isClosed) return;
      franchises.removeWhere((f) => f.franchiseCode == franchise.franchiseCode);
      if (selectedFranchiseCode.value == franchise.franchiseCode) {
        selectedFranchiseCode.value =
            franchises.isEmpty ? null : franchises.first.franchiseCode;
      }
      await loadFranchises(force: true);
      ErrorHandler.showSuccess(
        response.message.isEmpty
            ? 'Franchise deleted successfully.'
            : response.message,
        title: 'Deleted',
      );
    } catch (e) {
      if (isClosed) return;
      ErrorHandler.handleError(
        e,
        onNotFound: () {
          franchises.removeWhere(
            (f) => f.franchiseCode == franchise.franchiseCode,
          );
          if (selectedFranchiseCode.value == franchise.franchiseCode) {
            selectedFranchiseCode.value =
                franchises.isEmpty ? null : franchises.first.franchiseCode;
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
