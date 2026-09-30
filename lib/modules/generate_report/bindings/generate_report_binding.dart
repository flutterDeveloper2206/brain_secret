import 'package:get/get.dart';

import '../../../data/providers/api_service.dart';
import '../../../data/repositories/report_repo.dart';
import '../../../data/repositories/report_repo_impl.dart';
import '../controllers/generate_report_controller.dart';

class GenerateReportBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReportRepository>()) {
      Get.lazyPut<ReportRepository>(
        () => ReportRepositoryImpl(apiService: Get.find<ApiService>()),
      );
    }
    Get.lazyPut<GenerateReportController>(
      () => GenerateReportController(
        reportRepository: Get.find<ReportRepository>(),
      ),
    );
  }
}
