import 'package:get/get.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/entity_picker_result.dart';
import '../../../data/repositories/report_repo.dart';
import '../../../routes/app_routes.dart';

class GenerateReportController extends GetxController {
  GenerateReportController({required this.reportRepository});

  final ReportRepository reportRepository;

  final Rxn<EntityPickerResult> selectedEntity = Rxn<EntityPickerResult>();
  final RxBool isGenerating = false.obs;

  String get entityDisplayName {
    final entity = selectedEntity.value;
    if (entity == null) return '';
    if (entity.familyName.trim().isNotEmpty) return entity.familyName;
    return entity.customerName;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final entity = args?['entity'];
    if (entity is EntityPickerResult) {
      selectedEntity.value = entity;
    }
  }

  Future<void> openEntityPicker() async {
    final result = await Get.toNamed(Routes.entityPicker);
    if (result is EntityPickerResult) {
      selectedEntity.value = result;
    }
  }

  Future<void> generateReport() async {
    final entity = selectedEntity.value;
    if (entity == null) {
      GlassSnackbar.warning(
        'Please select a customer first',
        title: 'Missing',
      );
      return;
    }
    if (isGenerating.value) return;

    isGenerating.value = true;
    try {
      final ok = await reportRepository.generateAllReports(entity.familyId);
      if (!ok) {
        GlassSnackbar.error('Unable to generate reports.');
        return;
      }
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.back(result: true);
      GlassSnackbar.success('All reports generated', title: 'Success');
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isGenerating.value = false;
    }
  }
}
