import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../routes/app_routes.dart';

class StaffDetailsController extends GetxController {
  StaffDetailsController({required this.staffRepository});

  final StaffRepository staffRepository;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isToggling = false.obs;
  final Rxn<Staff> staff = Rxn<Staff>();

  late final int employeeId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      employeeId = args;
    } else if (args is Staff) {
      employeeId = args.employeeId;
      staff.value = args;
    } else if (args is Map && args['employeeId'] != null) {
      employeeId = int.tryParse(args['employeeId'].toString()) ?? 0;
      if (args['staff'] is Staff) {
        staff.value = args['staff'] as Staff;
      }
    } else {
      employeeId = int.tryParse(args?.toString() ?? '') ?? 0;
    }
    loadDetails();
  }

  Future<void> loadDetails() async {
    if (employeeId <= 0) {
      ErrorHandler.handleError(ServerException('Invalid employee id.'));
      return;
    }

    isLoading.value = true;
    try {
      final response = await staffRepository.getStaff(employeeId);
      staff.value = response.staff;
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isLoading.value = false;
    }
  }

  void openEdit() {
    final current = staff.value;
    if (current == null) return;
    Get.toNamed(
      Routes.staffProfile,
      arguments: {'employeeId': current.employeeId, 'staff': current},
    )?.then((result) {
      if (result == true) {
        loadDetails();
      }
    });
  }

  Future<void> toggleActive() async {
    final current = staff.value;
    if (current == null || isToggling.value) return;

    final nextLabel = current.isActive ? 'Inactive' : 'Active';
    final confirmed = await GlassPopup.confirm(
      title: 'Change Status',
      message:
          'Mark ${current.employeeFullName.isEmpty ? 'this staff member' : current.employeeFullName} as $nextLabel?',
      confirmText: 'Confirm',
    );
    if (!confirmed) return;

    isToggling.value = true;
    try {
      final response = await staffRepository.toggleStaffActive(
        current.employeeId,
      );
      await loadDetails();
      GlassSnackbar.success(
        response.message.isEmpty
            ? 'Staff status updated successfully.'
            : response.message,
        title: 'Status Updated',
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isToggling.value = false;
    }
  }

  Future<void> confirmDelete() async {
    final current = staff.value;
    if (current == null || isDeleting.value) return;

    final confirmed = await GlassPopup.confirm(
      title: 'Delete Staff',
      message:
          'Delete ${current.employeeFullName.isEmpty ? 'this staff member' : current.employeeFullName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    isDeleting.value = true;
    try {
      final response = await staffRepository.softDeleteStaff(
        current.employeeId,
      );
      // Pop before the snackbar, otherwise Get.back() closes the snackbar route.
      Get.back(result: true);
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        GlassSnackbar.success(
          response.message.isEmpty
              ? 'Staff deleted successfully.'
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
