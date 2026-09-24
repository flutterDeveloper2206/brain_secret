import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/create_franchise_request.dart';
import '../../../data/models/franchise.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../routes/app_routes.dart';

/// Minimal valid PDF used only in debug to skip the file picker.
Uint8List _dummyPanPdfBytes() {
  const pdf = '''%PDF-1.1
1 0 obj<< /Type /Catalog /Pages 2 0 R >>endobj
2 0 obj<< /Type /Pages /Kids [3 0 R] /Count 1 >>endobj
3 0 obj<< /Type /Page /Parent 2 0 R /MediaBox [0 0 300 144] /Contents 4 0 R /Resources<< /Font<< /F1 5 0 R >> >> >>endobj
4 0 obj<< /Length 68 >>stream
BT /F1 18 Tf 40 80 Td (DUMMY PAN CARD) Tj ET
endstream
endobj
5 0 obj<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000266 00000 n 
0000000384 00000 n 
trailer<< /Size 6 /Root 1 0 R >>
startxref
455
%%EOF
''';
  return Uint8List.fromList(utf8.encode(pdf));
}

class FranchiseProfileController extends GetxController {
  FranchiseProfileController({required this.franchiseRepository});

  final FranchiseRepository franchiseRepository;

  final formKey = GlobalKey<FormState>();

  final franchiseCodeController = TextEditingController(text: '0');
  final companyCodeController = TextEditingController(text: '1');
  final franchiseNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final gstNumberController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final pinController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isActive = true.obs;
  final RxBool mobileVerified = false.obs;
  final RxnString panDocName = RxnString();
  final Rxn<FranchisePanFile> panDocFile = Rxn<FranchisePanFile>();
  final RxnString existingPanUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    mobileController.addListener(_syncMobileVerified);
    _bootstrapFromArgs();
  }

  void _bootstrapFromArgs() {
    final args = Get.arguments;
    if (args is Franchise) {
      final code = args.franchiseCode;
      if (code > 0) {
        isEditMode.value = true;
        applyFranchise(args);
        loadFranchise(code); // Always refresh — list args can be stale.
      }
      return;
    }
    if (args is Map && args['franchiseCode'] != null) {
      final code = int.tryParse(args['franchiseCode'].toString()) ?? 0;
      if (code > 0) {
        isEditMode.value = true;
        loadFranchise(code);
      }
    }
  }

  Future<void> loadFranchise(int franchiseCode) async {
    isLoading.value = true;
    try {
      final response = await franchiseRepository.getFranchise(franchiseCode);
      final franchise = response.franchise;
      if (franchise != null) {
        applyFranchise(franchise);
      }
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isLoading.value = false;
    }
  }

  void applyFranchise(Franchise franchise) {
    franchiseCodeController.text = franchise.franchiseCode.toString();
    companyCodeController.text = franchise.companyCode.toString();
    franchiseNameController.text = franchise.franchiseName;
    ownerNameController.text = franchise.ownerName;
    gstNumberController.text = franchise.gstNumber;
    mobileController.text = franchise.mobileNo;
    emailController.text = franchise.emailId;
    websiteController.text = franchise.website;
    countryController.text = franchise.country;
    stateController.text = franchise.state;
    cityController.text = franchise.city;
    addressController.text = franchise.fullAddress;
    pinController.text = franchise.pincode;
    bankNameController.text = franchise.bankName;
    accountHolderController.text = franchise.accountHolderName;
    accountNumberController.text = franchise.accountNumber;
    ifscController.text = franchise.ifscCode;
    isActive.value = franchise.isActive;
    if (franchise.panCardUrl.isNotEmpty) {
      existingPanUrl.value = franchise.panCardUrl;
      panDocName.value = franchise.panCardUrl.split('/').last;
    }
    _syncMobileVerified();
  }

  void _syncMobileVerified() {
    mobileVerified.value = mobileController.text.trim().length == 10;
  }

  Future<void> pickPanDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final extension = (file.extension ?? '').toLowerCase();
      const allowed = {'pdf', 'png', 'jpg', 'jpeg'};
      if (!allowed.contains(extension)) {
        GlassSnackbar.warning(
          'Please select a PDF or image file (png/jpg).',
          title: 'Invalid file',
        );
        return;
      }

      var bytes = file.bytes;
      if ((bytes == null || bytes.isEmpty) &&
          file.path != null &&
          file.path!.isNotEmpty) {
        bytes = await XFile(file.path!).readAsBytes();
      }
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Unable to read selected file.');
      }

      panDocFile.value = FranchisePanFile(bytes: bytes, fileName: file.name);
      panDocName.value = file.name;
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  void fillDebugData() {
    try {
      if (!isEditMode.value) {
        franchiseCodeController.text = '0';
      }
      companyCodeController.text = '1';
      franchiseNameController.text = 'Vadodara Wellness Center';
      ownerNameController.text = 'Amit Mehta';
      gstNumberController.text = '24LMNOP9012Q3Z7';
      mobileController.text = '9876543212';
      emailController.text = 'support@vadodarawellness.com';
      websiteController.text = 'https://www.vadodarawellness.com';
      countryController.text = 'India';
      stateController.text = 'Gujarat';
      cityController.text = 'Vadodara';
      addressController.text = 'C-303, Alkapuri, Vadodara, Gujarat';
      pinController.text = '390007';
      bankNameController.text = 'ICICI Bank';
      accountHolderController.text = 'Vadodara Wellness Center';
      accountNumberController.text = '345678901234';
      ifscController.text = 'ICIC0003456';
      isActive.value = true;
      if (kDebugMode && !isEditMode.value) {
        const name = 'dummy_pan_card.pdf';
        panDocFile.value = FranchisePanFile(
          bytes: _dummyPanPdfBytes(),
          fileName: name,
        );
        panDocName.value = name;
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  CreateFranchiseRequest _buildRequest() {
    return CreateFranchiseRequest(
      franchiseCode: int.tryParse(franchiseCodeController.text.trim()) ?? 0,
      companyCode: int.tryParse(companyCodeController.text.trim()) ?? 1,
      franchiseName: franchiseNameController.text.trim(),
      ownerName: ownerNameController.text.trim(),
      gstNumber: gstNumberController.text.trim(),
      mobileNo: mobileController.text.trim(),
      emailId: emailController.text.trim(),
      website: websiteController.text.trim(),
      country: countryController.text.trim(),
      state: stateController.text.trim(),
      city: cityController.text.trim(),
      fullAddress: addressController.text.trim(),
      pincode: pinController.text.trim(),
      bankName: bankNameController.text.trim(),
      accountHolderName: accountHolderController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      ifscCode: ifscController.text.trim(),
      isActive: isActive.value,
      isDelete: false,
    );
  }

  Future<void> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final panFile = panDocFile.value;
    if (!isEditMode.value && panFile == null) {
      GlassSnackbar.warning(
        'Please upload PAN card document.',
        title: 'PAN required',
      );
      return;
    }

    isSaving.value = true;
    try {
      final request = _buildRequest();
      final String message;
      final String title;
      if (isEditMode.value) {
        final response = await franchiseRepository.updateFranchise(
          request: request,
          panCard: panFile,
        );
        message = response.message.isEmpty
            ? 'Franchise updated successfully.'
            : response.message;
        title = 'Franchise Updated';
      } else {
        final response = await franchiseRepository.createFranchise(
          request: request,
          panCard: panFile!,
        );
        message = response.message.isEmpty
            ? 'Franchise submitted successfully.'
            : response.message;
        title = 'Franchise Created';
      }

      // Leave the form first so the snackbar shows on the franchises page.
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      } else {
        Get.offNamedUntil(
          Routes.franchises,
          (route) =>
              route.settings.name == Routes.home ||
              route.settings.name == Routes.franchises ||
              route.isFirst,
        );
      }

      Future<void>.delayed(const Duration(milliseconds: 150), () {
        ErrorHandler.showSuccess(message, title: title);
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
    franchiseCodeController.dispose();
    companyCodeController.dispose();
    franchiseNameController.dispose();
    ownerNameController.dispose();
    gstNumberController.dispose();
    mobileController.dispose();
    emailController.dispose();
    websiteController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pinController.dispose();
    bankNameController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    super.onClose();
  }
}
