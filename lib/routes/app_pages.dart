import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/analysis/bindings/analysis_binding.dart';
import '../modules/analysis/views/analysis_view.dart';
import '../modules/device_scan/bindings/device_scan_binding.dart';
import '../modules/device_scan/views/device_scan_view.dart';
import '../modules/hand_selector/bindings/hand_selector_binding.dart';
import '../modules/hand_selector/views/hand_selector_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.analysis,
      page: () => const AnalysisView(),
      binding: AnalysisBinding(),
    ),
    GetPage(
      name: Routes.deviceScan,
      page: () => const DeviceScanView(),
      binding: DeviceScanBinding(),
    ),
    GetPage(
      name: Routes.handSelector,
      page: () => const HandSelectorView(),
      binding: HandSelectorBinding(),
    ),
  ];
}
