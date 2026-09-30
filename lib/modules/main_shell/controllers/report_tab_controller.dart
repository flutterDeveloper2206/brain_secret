import 'package:get/get.dart';

import '../../../core/errors/error_handler.dart';
import '../../../data/models/customer_report.dart';
import '../../../data/models/entity_picker_result.dart';
import '../../../data/repositories/report_repo.dart';
import '../../../routes/app_routes.dart';

class ReportTabController extends GetxController {
  ReportTabController({required this.reportRepository});

  final ReportRepository reportRepository;

  final Rxn<EntityPickerResult> selectedEntity = Rxn<EntityPickerResult>();
  final RxList<CustomerReport> reports = <CustomerReport>[].obs;
  final RxBool isLoading = false.obs;

  bool get hasSelection => selectedEntity.value != null;

  String get selectionLabel {
    final entity = selectedEntity.value;
    if (entity == null) return '';
    if (entity.familyName.trim().isNotEmpty) return entity.familyName;
    return entity.customerName;
  }

  /// Reports grouped by [CustomerReport.reportName], newest first within group.
  Map<String, List<CustomerReport>> get groupedByReportName {
    final map = <String, List<CustomerReport>>{};
    for (final report in reports) {
      final key =
          report.reportName.trim().isEmpty ? 'Unknown' : report.reportName;
      map.putIfAbsent(key, () => <CustomerReport>[]).add(report);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.reportDatetime.compareTo(a.reportDatetime));
    }
    final keys = map.keys.toList()..sort();
    return {for (final key in keys) key: map[key]!};
  }

  Future<void> openEntityPicker() async {
    final result = await Get.toNamed(Routes.entityPicker);
    if (result is! EntityPickerResult) return;
    selectedEntity.value = result;
    reports.clear();
    await loadReports();
  }

  Future<void> loadReports() async {
    final entity = selectedEntity.value;
    if (entity == null) return;

    isLoading.value = true;
    try {
      final list =
          await reportRepository.getCustomerReports(entity.familyId);
      reports.assignAll(list);
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> refreshList() => loadReports();

  void openReportDetail(CustomerReport report) {
    Get.toNamed(Routes.reportDetail, arguments: {'report': report});
  }
}
