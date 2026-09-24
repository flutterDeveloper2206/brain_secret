import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/create_staff_request.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repo.dart';
import '../../../routes/app_routes.dart';

class StaffProfileController extends GetxController {
  StaffProfileController({required this.staffRepository});

  final StaffRepository staffRepository;

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final employeeIdController = TextEditingController(text: '0');
  final companyCodeController = TextEditingController(text: '1');
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final designationController = TextEditingController();
  final reportingManagerController = TextEditingController();
  final joiningDateController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();

  final RxnString gender = RxnString();
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final Rxn<DateTime> dateOfJoining = Rxn<DateTime>();
  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool mobileVerified = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool twoFactorEnabled = false.obs;
  final RxnString profilePhoto = RxnString();

  final RxBool viewClients = false.obs;
  final RxBool addClients = false.obs;
  final RxBool captureFingerprints = false.obs;
  final RxBool uploadReports = false.obs;
  final RxBool downloadReports = false.obs;
  final RxBool manageStaff = false.obs;
  final RxBool viewAnalytics = false.obs;

  /// Locked id for update — never rely only on the text field.
  int editingEmployeeId = 0;

  final genders = const ['Male', 'Female', 'Other', 'Prefer not to say'];

  String get screenTitle => isEditMode.value ? 'Edit Staff' : 'Create Staff';

  String get saveLabel =>
      isEditMode.value ? 'Update Staff' : 'Save Staff';

  @override
  void onInit() {
    super.onInit();
    mobileController.addListener(_syncMobileVerified);
    _bootstrapFromArgs();
  }

  void _syncMobileVerified() {
    mobileVerified.value = mobileController.text.trim().length == 10;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void pickProfilePhoto() {
    profilePhoto.value = 'profile_photo.jpg';
  }

  void _bootstrapFromArgs() {
    final args = Get.arguments;
    if (args is Staff) {
      final id = args.employeeId;
      if (id > 0) {
        _enterEditMode(id);
        applyStaff(args);
        loadStaff(id);
      }
      return;
    }
    if (args is int && args > 0) {
      _enterEditMode(args);
      loadStaff(args);
      return;
    }
    if (args is Map) {
      final staffArg = args['staff'];
      final idFromArgs =
          int.tryParse(args['employeeId']?.toString() ?? '') ?? 0;
      final id = staffArg is Staff && staffArg.employeeId > 0
          ? staffArg.employeeId
          : idFromArgs;
      if (id <= 0) return;

      _enterEditMode(id);
      if (staffArg is Staff) {
        applyStaff(staffArg);
      }
      loadStaff(id);
    }
  }

  void _enterEditMode(int employeeId) {
    isEditMode.value = true;
    if (employeeId > 0) {
      editingEmployeeId = employeeId;
      employeeIdController.text = '$employeeId';
    }
  }

  Future<void> loadStaff(int employeeId) async {
    isLoading.value = true;
    try {
      _enterEditMode(employeeId);
      final response = await staffRepository.getStaff(employeeId);
      final staff = response.staff;
      if (staff != null) {
        applyStaff(staff);
      }
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void applyStaff(Staff staff) {
    final id = staff.employeeId > 0 ? staff.employeeId : editingEmployeeId;
    if (id > 0) {
      editingEmployeeId = id;
      employeeIdController.text = '$id';
    }
    fullNameController.text = staff.employeeFullName;
    companyCodeController.text =
        staff.companyCode > 0 ? '${staff.companyCode}' : '1';
    gender.value = staff.gender.isEmpty ? null : staff.gender;
    _applyDateString(staff.dob, isDob: true);
    _applyDateString(staff.joiningDate, isDob: false);
    mobileController.text = staff.mobileNo;
    emailController.text = staff.emailId;
    departmentController.text = staff.departmentName;
    designationController.text = staff.designationName;
    if (staff.employeePhoto.isNotEmpty) {
      profilePhoto.value = staff.employeePhoto;
    }
    _syncMobileVerified();
  }

  void _applyDateString(String raw, {required bool isDob}) {
    final value = raw.trim();
    if (value.isEmpty) {
      if (isDob) {
        dateOfBirth.value = null;
        dobController.clear();
      } else {
        dateOfJoining.value = null;
        joiningDateController.clear();
      }
      return;
    }

    DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null && value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 3) {
        parsed = DateTime.tryParse(
          '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
        );
      }
    }
    if (parsed == null) return;

    if (isDob) {
      dateOfBirth.value = parsed;
      dobController.text = _formatDisplayDate(parsed);
    } else {
      dateOfJoining.value = parsed;
      joiningDateController.text = _formatDisplayDate(parsed);
    }
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    try {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: dateOfBirth.value ?? DateTime(now.year - 25),
        firstDate: DateTime(1920),
        lastDate: now,
      );
      if (picked == null) return;
      dateOfBirth.value = picked;
      dobController.text = _formatDisplayDate(picked);
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  Future<void> pickJoiningDate(BuildContext context) async {
    try {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: dateOfJoining.value ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 1),
      );
      if (picked == null) return;
      dateOfJoining.value = picked;
      joiningDateController.text = _formatDisplayDate(picked);
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatApiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void fillDebugData() {
    if (!kDebugMode || isEditMode.value) return;
    try {
      fullNameController.text = 'Sneha Joshi';
      companyCodeController.text = '1';
      employeeIdController.text = '0';
      gender.value = 'Female';
      final dob = DateTime(1997, 8, 5);
      dateOfBirth.value = dob;
      dobController.text = _formatDisplayDate(dob);
      mobileController.text = '9876543213';
      emailController.text = 'sneha.joshi@example.com';
      departmentController.text = 'Marketing';
      designationController.text = 'Marketing Executive';
      reportingManagerController.text = 'Anita Shah';
      final joining = DateTime(2024, 2, 12);
      dateOfJoining.value = joining;
      joiningDateController.text = _formatDisplayDate(joining);
      usernameController.text = 'sneha.joshi';
      passwordController.text = 'Test@123';
      _syncMobileVerified();
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  CreateStaffRequest? _buildRequest() {
    final dob = dateOfBirth.value;
    final joining = dateOfJoining.value;
    if (dob == null || joining == null) return null;

    final parsedId = int.tryParse(employeeIdController.text.trim()) ?? 0;
    final employeeId = editingEmployeeId > 0 ? editingEmployeeId : parsedId;

    return CreateStaffRequest(
      employeeId: employeeId,
      companyCode: int.tryParse(companyCodeController.text.trim()) ?? 1,
      employeeFullName: fullNameController.text.trim(),
      gender: gender.value ?? '',
      dob: _formatApiDate(dob),
      mobileNo: mobileController.text.trim(),
      emailId: emailController.text.trim(),
      departmentName: departmentController.text.trim(),
      designationName: designationController.text.trim(),
      joiningDate: _formatApiDate(joining),
      isActive: true,
      isDelete: false,
    );
  }

  Future<void> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      GlassSnackbar.warning(
        'Please fill all required fields before saving.',
        title: 'Incomplete form',
      );
      return;
    }

    final request = _buildRequest();
    if (request == null) {
      GlassSnackbar.warning(
        'Date of birth and joining date are required.',
        title: 'Incomplete form',
      );
      return;
    }

    final shouldUpdate = isEditMode.value || request.employeeId > 0;
    if (shouldUpdate && request.employeeId <= 0) {
      GlassSnackbar.error(
        'Employee id is missing. Open the staff again from the list.',
        title: 'Update failed',
      );
      return;
    }

    isSaving.value = true;
    try {
      final response = shouldUpdate
          ? await staffRepository.updateStaff(request)
          : await staffRepository.createStaff(request);

      final successMessage = response.message.isEmpty
          ? (shouldUpdate
                ? 'Staff updated successfully.'
                : 'Staff created successfully.')
          : response.message;
      final successTitle = shouldUpdate ? 'Staff Updated' : 'Staff Created';

      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      } else {
        Get.offNamedUntil(
          Routes.staffs,
          (route) =>
              route.settings.name == Routes.home || route.isFirst,
        );
      }

      Future<void>.delayed(const Duration(milliseconds: 150), () {
        ErrorHandler.showSuccess(successMessage, title: successTitle);
      });
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  @override
  void onClose() {
    mobileController.removeListener(_syncMobileVerified);
    fullNameController.dispose();
    employeeIdController.dispose();
    companyCodeController.dispose();
    mobileController.dispose();
    emailController.dispose();
    departmentController.dispose();
    designationController.dispose();
    reportingManagerController.dispose();
    joiningDateController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
