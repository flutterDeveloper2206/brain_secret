import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/login_data_session.dart';
import '../../../data/models/login_request.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/permissions_repo.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  LoginController({
    required this.authRepository,
    required this.permissionsRepository,
    required this.userRepository,
    required this.permissionService,
    required this.apiService,
  });

  final AuthRepository authRepository;
  final PermissionsRepository permissionsRepository;
  final UserRepository userRepository;
  final PermissionService permissionService;
  final ApiService apiService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    try {
      final request = LoginRequest(
        userName: emailController.text.trim(),
        password: passwordController.text,
        deviceType: _deviceType,
        deviceId: _deviceId,
        fcmToken: 'pending_fcm_token',
        appVersion: AppConstants.appVersion,
      );

      final response = await authRepository.login(request);
      final data = response.data!;

      final session = LoginDataSession(
        token: data.token,
        expiresAt: data.expiresAt,
        userType: data.userType,
      );

      // Persist token then load permissions into SQLite.
      await permissionService.saveSession(session);
      apiService.setAuthToken(data.token);

      try {
        final permissions = await permissionsRepository.fetchUserPermissions();
        await permissionService.applyPermissions(permissions);
      } catch (e) {
        // Auth succeeded — don't block home if permissions endpoint fails.
        if (kDebugMode) {
          debugPrint('Permissions load failed after login: $e');
        }
        GlassSnackbar.warning(
          'Signed in, but permissions could not be loaded.',
          title: 'Partial login',
        );
      }

      try {
        final userResponse = await userRepository.getCurrentUser();
        await permissionService.setUserProfile(userResponse.user);
      } catch (_) {
        // Profile fetch is non-blocking; dashboard/menu can still load.
        permissionService.clearUserProfile();
      }

      Get.offAllNamed(Routes.home);
      GlassSnackbar.success(
        response.message.isEmpty ? 'Signed in successfully.' : response.message,
        title: 'Welcome',
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  String get _deviceType {
    if (kIsWeb) return 'WEB';
    return 'MOBILE';
  }

  String get _deviceId {
    if (kIsWeb) return 'web_browser';
    return defaultTargetPlatform.name;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
