import 'package:get/get.dart';
import '../modules/analysis/bindings/analysis_binding.dart';
import '../modules/analysis/views/analysis_view.dart';
import '../modules/device_scan/bindings/device_scan_binding.dart';
import '../modules/device_scan/views/device_scan_view.dart';
import '../modules/hand_selector/bindings/hand_selector_binding.dart';
import '../modules/hand_selector/views/hand_selector_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_shell/bindings/main_shell_binding.dart';
import '../modules/main_shell/views/main_shell_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/customer_profile/bindings/customer_profile_binding.dart';
import '../modules/customer_profile/views/customer_profile_view.dart';
import '../modules/customer_details/bindings/customer_details_binding.dart';
import '../modules/customer_details/views/customer_details_view.dart';
import '../modules/customers/bindings/customers_binding.dart';
import '../modules/customers/views/customers_view.dart';
import '../modules/franchise_profile/bindings/franchise_profile_binding.dart';
import '../modules/franchise_profile/views/franchise_profile_view.dart';
import '../modules/franchise_details/bindings/franchise_details_binding.dart';
import '../modules/franchise_details/views/franchise_details_view.dart';
import '../modules/franchises/bindings/franchises_binding.dart';
import '../modules/franchises/views/franchises_view.dart';
import '../modules/staff_profile/bindings/staff_profile_binding.dart';
import '../modules/staff_profile/views/staff_profile_view.dart';
import '../modules/staffs/bindings/staffs_binding.dart';
import '../modules/staffs/views/staffs_view.dart';
import '../modules/staff_details/bindings/staff_details_binding.dart';
import '../modules/staff_details/views/staff_details_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
    ),
    GetPage(
      name: Routes.customerDetails,
      page: () => const CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
    ),
    GetPage(
      name: Routes.customerProfile,
      page: () => const CustomerProfileView(),
      binding: CustomerProfileBinding(),
    ),
    GetPage(
      name: Routes.franchises,
      page: () => const FranchisesView(),
      binding: FranchisesBinding(),
    ),
    GetPage(
      name: Routes.franchiseDetails,
      page: () => const FranchiseDetailsView(),
      binding: FranchiseDetailsBinding(),
    ),
    GetPage(
      name: Routes.franchiseProfile,
      page: () => const FranchiseProfileView(),
      binding: FranchiseProfileBinding(),
    ),
    GetPage(
      name: Routes.staffProfile,
      page: () => const StaffProfileView(),
      binding: StaffProfileBinding(),
    ),
    GetPage(
      name: Routes.staffs,
      page: () => const StaffsView(),
      binding: StaffsBinding(),
    ),
    GetPage(
      name: Routes.staffDetails,
      page: () => const StaffDetailsView(),
      binding: StaffDetailsBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
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
