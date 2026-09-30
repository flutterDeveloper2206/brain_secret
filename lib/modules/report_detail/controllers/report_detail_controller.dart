import 'package:get/get.dart';

import '../../../data/models/customer_report.dart';

class ReportDetailController extends GetxController {
  CustomerReport? report;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final value = args?['report'];
    if (value is CustomerReport) {
      report = value;
    } else {
      Future.microtask(Get.back);
    }
  }

  List<MapEntry<String, String>> get displayEntries {
    final data = report?.reportResult;
    if (data == null) return const [];
    final entries = <MapEntry<String, String>>[];
    data.forEach((key, value) {
      if (value == null) {
        entries.add(MapEntry(key, '—'));
      } else {
        entries.add(MapEntry(key, value.toString()));
      }
    });
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }
}
