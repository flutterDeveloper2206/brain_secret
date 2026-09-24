import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../data/models/get_all_staff_request.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../routes/app_routes.dart';

class StaffsController extends GetxController {
  StaffsController({required this.staffRepository});

  final StaffRepository staffRepository;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isToggling = false.obs;
  final RxList<Staff> staffList = <Staff>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnInt selectedEmployeeId = RxnInt();

  final searchController = TextEditingController();

  int companyCode = 1;

  @override
  void onInit() {
    super.onInit();
    loadStaff();
  }

  List<Staff> get filteredStaff {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return staffList.toList();
    return staffList.where((staff) {
      final haystack = [
        staff.employeeFullName,
        staff.mobileNo,
        staff.emailId,
        staff.departmentName,
        staff.designationName,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Staff? get selectedStaff {
    final id = selectedEmployeeId.value;
    if (id == null) return null;
    for (final staff in staffList) {
      if (staff.employeeId == id) return staff;
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

  void selectStaff(Staff staff) {
    if (isClosed) return;
    selectedEmployeeId.value = staff.employeeId;
  }

  Future<void> loadStaff({bool force = false}) async {
    if (isClosed || (isLoading.value && !force)) return;
    isLoading.value = true;
    try {
      final response = await staffRepository.getAllStaff(
        GetAllStaffRequest(companyCode: companyCode),
      );
      if (isClosed) return;
      staffList.assignAll(response.staffList);
      final selected = selectedEmployeeId.value;
      if (selected != null &&
          staffList.every((s) => s.employeeId != selected)) {
        selectedEmployeeId.value =
            staffList.isEmpty ? null : staffList.first.employeeId;
      } else if (selected == null && staffList.isNotEmpty) {
        selectedEmployeeId.value = staffList.first.employeeId;
      } else if (staffList.isEmpty) {
        selectedEmployeeId.value = null;
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void openCreateStaff() {
    Get.toNamed(Routes.staffProfile)?.then((result) {
      if (isClosed) return;
      if (result == true) loadStaff(force: true);
    });
  }

  void openStaffDetails(Staff staff) {
    selectStaff(staff);
    Get.toNamed(
      Routes.staffDetails,
      arguments: staff.employeeId,
    )?.then((result) async {
      if (isClosed) return;
      if (result == true) {
        staffList.removeWhere((s) => s.employeeId == staff.employeeId);
        if (selectedEmployeeId.value == staff.employeeId) {
          selectedEmployeeId.value =
              staffList.isEmpty ? null : staffList.first.employeeId;
        }
      }
      await loadStaff(force: true);
    });
  }

  void openEditSelected() {
    final staff = selectedStaff;
    if (staff == null) return;
    Get.toNamed(
      Routes.staffProfile,
      arguments: {'employeeId': staff.employeeId, 'staff': staff},
    )?.then((result) {
      if (isClosed) return;
      if (result == true) loadStaff(force: true);
    });
  }

  Future<void> toggleActive(Staff staff) async {
    if (isClosed || isToggling.value) return;
    final nextLabel = staff.isActive ? 'Inactive' : 'Active';
    final confirmed = await GlassPopup.confirm(
      title: 'Change Status',
      message:
          'Mark ${staff.employeeFullName.isEmpty ? 'this staff member' : staff.employeeFullName} as $nextLabel?',
      confirmText: 'Confirm',
    );
    if (!confirmed || isClosed) return;

    isToggling.value = true;
    try {
      final response = await staffRepository.toggleStaffActive(
        staff.employeeId,
      );
      if (isClosed) return;
      await loadStaff(force: true);
      ErrorHandler.showSuccess(
        response.message.isEmpty
            ? 'Staff status updated successfully.'
            : response.message,
        title: 'Status Updated',
      );
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isToggling.value = false;
    }
  }

  Future<void> confirmDelete(Staff staff) async {
    if (isClosed || isDeleting.value) return;
    final confirmed = await GlassPopup.confirm(
      title: 'Delete Staff',
      message:
          'Delete ${staff.employeeFullName.isEmpty ? 'this staff member' : staff.employeeFullName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || isClosed) return;

    isDeleting.value = true;
    try {
      final response = await staffRepository.softDeleteStaff(
        staff.employeeId,
      );
      if (isClosed) return;
      staffList.removeWhere((s) => s.employeeId == staff.employeeId);
      if (selectedEmployeeId.value == staff.employeeId) {
        selectedEmployeeId.value =
            staffList.isEmpty ? null : staffList.first.employeeId;
      }
      await loadStaff(force: true);
      ErrorHandler.showSuccess(
        response.message.isEmpty
            ? 'Staff deleted successfully.'
            : response.message,
        title: 'Deleted',
      );
    } catch (e) {
      if (isClosed) return;
      ErrorHandler.handleError(
        e,
        onNotFound: () {
          staffList.removeWhere((s) => s.employeeId == staff.employeeId);
          if (selectedEmployeeId.value == staff.employeeId) {
            selectedEmployeeId.value =
                staffList.isEmpty ? null : staffList.first.employeeId;
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
