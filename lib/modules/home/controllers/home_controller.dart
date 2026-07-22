import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FingerprintRepository repository;

  HomeController({required this.repository});

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> scanFingerprint() async {
    isLoading.value = true;
    try {
      final Uint8List bytes = await repository.scanFingerprint();
      // Navigate to the Analysis Screen passing image bytes as argument
      Get.toNamed(
        Routes.analysis,
        arguments: {'bytes': bytes, 'isScanned': true},
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> scanFingerprintDevice() async {
    isLoading.value = true;
    try {
      final Uint8List bytes = await repository.scanFingerprintDevice();
      Get.toNamed(
        Routes.analysis,
        arguments: {'bytes': bytes, 'isScanned': true},
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    isLoading.value = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        Get.toNamed(
          Routes.analysis,
          arguments: {'bytes': bytes, 'isScanned': false},
        );
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
