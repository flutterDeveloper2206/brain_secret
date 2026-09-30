import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../routes/app_routes.dart';

class MainShellController extends GetxController {
  MainShellController({
    required this.authRepository,
    required this.permissionService,
    required this.apiService,
  });

  final AuthRepository authRepository;
  final PermissionService permissionService;
  final ApiService apiService;

  final RxInt currentIndex = 0.obs;
  final RxBool isLoggingOut = false.obs;

  static const int dashboardTabIndex = 0;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Report/Menu back → Dashboard; Dashboard back → exit confirm.
  Future<void> handleSystemBack() async {
    if (currentIndex.value != dashboardTabIndex) {
      changeTab(dashboardTabIndex);
      return;
    }
    await confirmExitApp();
  }

  Future<void> confirmExitApp() async {
    final confirmed = await GlassPopup.confirm(
      title: 'Exit app',
      message: 'Are you sure you want to exit?',
      cancelText: 'Cancel',
      confirmText: 'Exit',
      isDestructive: true,
    );

    if (confirmed) {
      await SystemNavigator.pop();
    }
  }

  Future<void> confirmLogout() async {
    if (isLoggingOut.value) return;

    final confirmed = await GlassPopup.confirm(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      cancelText: 'Cancel',
      confirmText: 'OK',
      isDestructive: true,
    );

    if (confirmed) {
      await logout();
    }
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await authRepository.logout();
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      await permissionService.clearAll();
      apiService.setAuthToken(null);
      isLoggingOut.value = false;
      Get.offAllNamed(Routes.login);
    }
  }
}
