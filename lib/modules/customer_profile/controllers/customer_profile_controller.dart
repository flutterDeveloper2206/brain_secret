import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/customer_request.dart';
import '../../../data/models/family_member.dart';
import '../../../data/models/franchise_dropdown.dart';
import '../../../data/repositories/customer_repo.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../routes/app_routes.dart';

class FamilyMemberFormItem {
  FamilyMemberFormItem({
    String fullName = '',
    String email = '',
    String education = '',
    String age = '',
    String emergencyContact = '',
    DateTime? dob,
  }) : fullNameController = TextEditingController(text: fullName),
       emailController = TextEditingController(text: email),
       educationController = TextEditingController(text: education),
       ageController = TextEditingController(text: age),
       emergencyContactController = TextEditingController(
         text: emergencyContact,
       ),
       dateOfBirthController = TextEditingController(),
       dateOfBirth = Rxn<DateTime>(dob) {
    if (dob != null) {
      dateOfBirthController.text = _formatDisplayDob(dob);
    }
  }

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController educationController;
  final TextEditingController ageController;
  final TextEditingController emergencyContactController;
  final TextEditingController dateOfBirthController;
  final Rxn<DateTime> dateOfBirth;

  factory FamilyMemberFormItem.fromMember(FamilyMember member) {
    final item = FamilyMemberFormItem(
      fullName: member.customerFullName,
      email: member.emailId,
      education: member.education,
      age: member.age > 0 ? '${member.age}' : '',
      emergencyContact: member.emergencyContact,
    );
    item.applyDobString(member.dob);
    return item;
  }

  void setDateOfBirth(DateTime dob) {
    dateOfBirth.value = dob;
    dateOfBirthController.text = _formatDisplayDob(dob);
    ageController.text = _calculateAge(dob).toString();
  }

  void applyDobString(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      dateOfBirth.value = null;
      dateOfBirthController.clear();
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
    if (parsed != null) {
      setDateOfBirth(parsed);
    }
  }

  String get apiDob {
    final dob = dateOfBirth.value;
    if (dob == null) return '';
    return '${dob.year}-'
        '${dob.month.toString().padLeft(2, '0')}-'
        '${dob.day.toString().padLeft(2, '0')}';
  }

  FamilyMember toFamilyMember() {
    return FamilyMember(
      customerFullName: fullNameController.text.trim(),
      emailId: emailController.text.trim(),
      education: educationController.text.trim(),
      age: int.tryParse(ageController.text.trim()) ?? 0,
      emergencyContact: emergencyContactController.text.trim(),
      dob: apiDob,
    );
  }

  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    educationController.dispose();
    ageController.dispose();
    emergencyContactController.dispose();
    dateOfBirthController.dispose();
  }

  static String _formatDisplayDob(DateTime dob) {
    return '${dob.day.toString().padLeft(2, '0')}/'
        '${dob.month.toString().padLeft(2, '0')}/'
        '${dob.year}';
  }

  static int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }
}

class CustomerProfileController extends GetxController {
  CustomerProfileController({
    required this.customerRepository,
    required this.franchiseRepository,
  });

  final CustomerRepository customerRepository;
  final FranchiseRepository franchiseRepository;

  final formKey = GlobalKey<FormState>();

  final customerIdController = TextEditingController(text: '0');
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final photoUrlController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final pinCodeController = TextEditingController();
  final fullAddressController = TextEditingController();
  final occupationController = TextEditingController();
  final companyController = TextEditingController();
  final educationController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final spouseNameController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final companyCodeController = TextEditingController(text: '1');
  final franchiseCodeController = TextEditingController(text: '1');

  final RxnString gender = RxnString();
  final RxnString maritalStatus = RxnString();
  final RxnString preferredLanguage = RxnString();
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool mobileVerified = false.obs;
  final RxBool hasMedicalIssue = false.obs;
  final RxBool hasPsychologicalIssue = false.obs;
  final RxBool isRightHandDominant = true.obs;
  final RxBool isEditMode = false.obs;
  final RxList<FranchiseDropdownItem> franchiseOptions =
      <FranchiseDropdownItem>[].obs;
  final RxnInt selectedFranchiseCode = RxnInt();
  final RxList<FamilyMemberFormItem> familyMembers =
      <FamilyMemberFormItem>[].obs;

  /// Locked id for update — never rely only on the text field.
  int editingCustomerId = 0;

  final genders = const ['Male', 'Female', 'Other', 'Prefer not to say'];
  final maritalStatuses = const ['Single', 'Married', 'Divorced', 'Widowed'];
  final languages = const ['English', 'Hindi', 'Gujarati', 'Marathi', 'Other'];

  @override
  void onInit() {
    super.onInit();
    mobileController.addListener(_syncMobileVerified);
    _bootstrapFromArgs();
    loadFranchiseDropdown();
  }

  Future<void> loadFranchiseDropdown() async {
    try {
      final companyCode =
          int.tryParse(companyCodeController.text.trim()) ?? 1;
      final response = await franchiseRepository.getFranchiseDropdown(
        companyCode,
      );
      final unique = <FranchiseDropdownItem>[];
      final seen = <int>{};
      for (final item in response.items) {
        if (item.franchiseCode <= 0) continue;
        if (!seen.add(item.franchiseCode)) continue;
        unique.add(item);
      }
      franchiseOptions.assignAll(unique);

      final current =
          selectedFranchiseCode.value ??
          int.tryParse(franchiseCodeController.text.trim());
      if (current != null &&
          current > 0 &&
          franchiseOptions.any((e) => e.franchiseCode == current)) {
        selectedFranchiseCode.value = current;
        franchiseCodeController.text = '$current';
      } else if (!isEditMode.value &&
          (selectedFranchiseCode.value == null ||
              (selectedFranchiseCode.value ?? 0) <= 0) &&
          franchiseOptions.isNotEmpty) {
        selectedFranchiseCode.value = franchiseOptions.first.franchiseCode;
        franchiseCodeController.text =
            '${franchiseOptions.first.franchiseCode}';
      } else if (current == null || current <= 0) {
        selectedFranchiseCode.value = null;
      }
    } catch (e) {
      // Dropdown is optional for save — keep typed/existing franchise code.
      ErrorHandler.handleError(e);
    }
  }

  void onFranchiseSelected(int? code) {
    if (code == null || code <= 0) {
      selectedFranchiseCode.value = null;
      return;
    }
    selectedFranchiseCode.value = code;
    franchiseCodeController.text = '$code';
  }

  void addFamilyMember() {
    familyMembers.add(FamilyMemberFormItem());
  }

  void removeFamilyMember(int index) {
    if (index < 0 || index >= familyMembers.length) return;
    final item = familyMembers.removeAt(index);
    item.dispose();
  }

  void _clearFamilyMembers() {
    for (final item in familyMembers) {
      item.dispose();
    }
    familyMembers.clear();
  }

  void _setFamilyMembers(List<FamilyMember> members) {
    _clearFamilyMembers();
    for (final member in members) {
      familyMembers.add(FamilyMemberFormItem.fromMember(member));
    }
  }

  Future<void> pickFamilyMemberDob(BuildContext context, int index) async {
    if (index < 0 || index >= familyMembers.length) return;
    try {
      final item = familyMembers[index];
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: item.dateOfBirth.value ?? DateTime(now.year - 12),
        firstDate: DateTime(1920),
        lastDate: now,
      );
      if (picked == null) return;
      item.setDateOfBirth(picked);
      familyMembers.refresh();
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  void _bootstrapFromArgs() {
    final args = Get.arguments;
    if (args is Customer) {
      final id = args.customerId;
      if (id > 0) {
        _enterEditMode(id);
        applyCustomer(args);
        loadCustomer(id); // Always refresh — list/details args can be stale.
      }
      return;
    }
    if (args is int && args > 0) {
      _enterEditMode(args);
      loadCustomer(args);
      return;
    }
    if (args is Map) {
      final customerArg = args['customer'];
      final idFromArgs =
          int.tryParse(args['customerId']?.toString() ?? '') ?? 0;
      final id = customerArg is Customer && customerArg.customerId > 0
          ? customerArg.customerId
          : idFromArgs;
      if (id <= 0) return;

      _enterEditMode(id);
      if (customerArg is Customer) {
        applyCustomer(customerArg);
      }
      loadCustomer(id);
    }
  }

  void _enterEditMode(int customerId) {
    isEditMode.value = true;
    if (customerId > 0) {
      editingCustomerId = customerId;
      customerIdController.text = '$customerId';
    }
  }

  Future<void> loadCustomer(int customerId) async {
    isLoading.value = true;
    try {
      _enterEditMode(customerId);
      final response = await customerRepository.getCustomer(customerId);
      final customer = response.customer;
      if (customer != null) {
        applyCustomer(customer);
      }
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isLoading.value = false;
    }
  }

  void applyCustomer(Customer customer) {
    final id = customer.customerId > 0
        ? customer.customerId
        : editingCustomerId;
    if (id > 0) {
      editingCustomerId = id;
      customerIdController.text = '$id';
    } else {
      customerIdController.text = customer.customerId.toString();
    }
    fullNameController.text = customer.customerFullName;
    emailController.text = customer.emailId;
    mobileController.text = customer.mobileNo;
    gender.value = customer.gender.isEmpty ? null : customer.gender;
    _applyDobString(customer.dob);
    ageController.text = customer.age > 0 ? customer.age.toString() : '';
    photoUrlController.text = customer.photoUrl;
    countryController.text = customer.countryName;
    stateController.text = customer.stateName;
    cityController.text = customer.cityName;
    pinCodeController.text = customer.pincode;
    fullAddressController.text = customer.fullAddress;
    occupationController.text = customer.occupation;
    companyController.text = customer.organization;
    educationController.text = customer.education;
    maritalStatus.value = customer.maritalStatus.isEmpty
        ? null
        : customer.maritalStatus;
    preferredLanguage.value = customer.preferredLanguage.isEmpty
        ? null
        : customer.preferredLanguage;
    fatherNameController.text = customer.fatherName;
    motherNameController.text = customer.motherName;
    spouseNameController.text = customer.spouseName;
    emergencyContactController.text = customer.emergencyContact;
    hasMedicalIssue.value = customer.anyMedicalIssue;
    hasPsychologicalIssue.value = customer.anyPsychologicalIssue;
    isRightHandDominant.value = customer.leftRightHandDominat;
    companyCodeController.text = customer.companyCode > 0
        ? customer.companyCode.toString()
        : '1';
    if (customer.franchiseCode > 0) {
      franchiseCodeController.text = customer.franchiseCode.toString();
      selectedFranchiseCode.value = customer.franchiseCode;
    } else {
      selectedFranchiseCode.value = null;
    }
    _setFamilyMembers(customer.familyMembers);
    _syncMobileVerified();
  }

  void _applyDobString(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      dateOfBirth.value = null;
      dateOfBirthController.clear();
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
    if (parsed != null) {
      setDateOfBirth(parsed);
    }
  }

  void _syncMobileVerified() {
    mobileVerified.value = mobileController.text.trim().length == 10;
  }

  void fillDebugData() {
    try {
      if (!isEditMode.value) {
        customerIdController.text = '0';
      }
      fullNameController.text = 'Rahul Patel';
      emailController.text = 'rahul.patel@example.com';
      mobileController.text = '9876543212';
      gender.value = 'Male';
      setDateOfBirth(DateTime(1988, 11, 10));
      photoUrlController.text =
          'https://example.com/images/customers/rahul-patel.jpg';
      countryController.text = 'India';
      stateController.text = 'Gujarat';
      cityController.text = 'Surat';
      pinCodeController.text = '395007';
      fullAddressController.text = 'C-305, Silver Heights, Surat, Gujarat';
      occupationController.text = 'Business Owner';
      companyController.text = 'Patel Textiles';
      educationController.text = 'MBA';
      maritalStatus.value = 'Married';
      preferredLanguage.value = 'Gujarati';
      fatherNameController.text = 'Mahesh Patel';
      motherNameController.text = 'Anita Patel';
      spouseNameController.text = 'Neha Patel';
      emergencyContactController.text = '9876501236';
      hasMedicalIssue.value = true;
      hasPsychologicalIssue.value = false;
      isRightHandDominant.value = true;
      companyCodeController.text = '1';
      franchiseCodeController.text = '1';
      _setFamilyMembers([
        const FamilyMember(
          customerFullName: 'Prem',
          emailId: 'prem@gmail.com',
          education: '5th',
          age: 12,
          emergencyContact: '9876501236',
          dob: '2015-01-20',
        ),
        const FamilyMember(
          customerFullName: 'Pritam',
          emailId: 'Pritam@gmail.com',
          education: '5th',
          age: 12,
          emergencyContact: '9876501236',
          dob: '2015-01-20',
        ),
      ]);
    } catch (e) {
      ErrorHandler.handleError(e);
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
      setDateOfBirth(picked);
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  void setDateOfBirth(DateTime dob) {
    dateOfBirth.value = dob;
    dateOfBirthController.text = dateOfBirthLabel;
    ageController.text = _calculateAge(dob).toString();
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  String get dateOfBirthLabel {
    final dob = dateOfBirth.value;
    if (dob == null) return '';
    return '${dob.day.toString().padLeft(2, '0')}/'
        '${dob.month.toString().padLeft(2, '0')}/'
        '${dob.year}';
  }

  String get _dobApiValue {
    final dob = dateOfBirth.value;
    if (dob == null) return '';
    return '${dob.year}-'
        '${dob.month.toString().padLeft(2, '0')}-'
        '${dob.day.toString().padLeft(2, '0')}';
  }

  String get screenTitle =>
      isEditMode.value ? 'Edit Customer' : 'Create Customer';

  String get saveLabel =>
      isEditMode.value ? 'Update Customer' : 'Save Customer';

  CustomerRequest _buildRequest() {
    final parsedId = int.tryParse(customerIdController.text.trim()) ?? 0;
    final customerId = editingCustomerId > 0 ? editingCustomerId : parsedId;

    final franchiseCode =
        selectedFranchiseCode.value ??
        int.tryParse(franchiseCodeController.text.trim()) ??
        0;

    return CustomerRequest(
      customerId: customerId,
      customerFullName: fullNameController.text.trim(),
      emailId: emailController.text.trim(),
      mobileNo: mobileController.text.trim(),
      gender: gender.value ?? '',
      dob: _dobApiValue,
      age: int.tryParse(ageController.text.trim()) ?? 0,
      photoUrl: photoUrlController.text.trim(),
      countryName: countryController.text.trim(),
      stateName: stateController.text.trim(),
      cityName: cityController.text.trim(),
      pincode: pinCodeController.text.trim(),
      fullAddress: fullAddressController.text.trim(),
      occupation: occupationController.text.trim(),
      organization: companyController.text.trim(),
      education: educationController.text.trim(),
      maritalStatus: maritalStatus.value ?? '',
      preferredLanguage: preferredLanguage.value ?? '',
      fatherName: fatherNameController.text.trim(),
      motherName: motherNameController.text.trim(),
      spouseName: spouseNameController.text.trim(),
      emergencyContact: emergencyContactController.text.trim(),
      anyMedicalIssue: hasMedicalIssue.value,
      anyPsychologicalIssue: hasPsychologicalIssue.value,
      leftRightHandDominat: isRightHandDominant.value,
      companyCode: int.tryParse(companyCodeController.text.trim()) ?? 0,
      franchiseCode: franchiseCode,
      // Backend treats missing is_active as false and hides the row from list.
      isActive: true,
      isDelete: false,
      familyMembers: familyMembers.map((e) => e.toFamilyMember()).toList(),
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

    final selectedCode = selectedFranchiseCode.value;
    if (selectedCode != null && selectedCode > 0) {
      franchiseCodeController.text = '$selectedCode';
    }

    final request = _buildRequest();
    final shouldUpdate = isEditMode.value || request.customerId > 0;

    if (shouldUpdate && request.customerId <= 0) {
      GlassSnackbar.error(
        'Customer id is missing. Open the customer again from the list.',
        title: 'Update failed',
      );
      return;
    }

    isSaving.value = true;
    try {
      final response = shouldUpdate
          ? await customerRepository.updateCustomer(request)
          : await customerRepository.createCustomer(request);

      final successMessage = response.message.isEmpty
          ? (shouldUpdate
                ? 'Customer updated successfully.'
                : 'Customer created successfully.')
          : response.message;
      final successTitle =
          shouldUpdate ? 'Customer Updated' : 'Customer Created';

      // Leave the form first so the snackbar shows on the customers page.
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      } else {
        Get.offNamedUntil(
          Routes.customers,
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
    customerIdController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    ageController.dispose();
    dateOfBirthController.dispose();
    photoUrlController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    fullAddressController.dispose();
    occupationController.dispose();
    companyController.dispose();
    educationController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    spouseNameController.dispose();
    emergencyContactController.dispose();
    companyCodeController.dispose();
    franchiseCodeController.dispose();
    _clearFamilyMembers();
    super.onClose();
  }
}
