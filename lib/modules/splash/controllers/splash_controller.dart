import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/permissions_repo.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController({
    required this.apiService,
    required this.permissionService,
    required this.permissionsRepository,
  });

  final ApiService apiService;
  final PermissionService permissionService;
  final PermissionsRepository permissionsRepository;

  bool _didNavigate = false;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_didNavigate) return;
    try {
      await Future.wait([
        Future<void>.delayed(AppConstants.splashDuration),
        _resolveSession(),
      ]);
    } catch (e) {
      ErrorHandler.handleError(e);
      await _goLogin();
    }
  }

  Future<void> _resolveSession() async {
    await permissionService.hydrateFromLocal();
    final token = permissionService.token;

    // No token → do not call permissions API; go to login.
    if (token == null || token.isEmpty) {
      await _goLogin();
      return;
    }

    apiService.setAuthToken(token);

    try {
      final permissions = await permissionsRepository.fetchUserPermissions();
      await permissionService.applyPermissions(permissions);
      await _goHome();
    } catch (e) {
      // Invalid/expired token → clear and force login.
      await permissionService.clearAll();
      apiService.setAuthToken(null);
      ErrorHandler.handleError(e);
      await _goLogin();
    }
  }

  Future<void> _goLogin() async {
    if (_didNavigate || isClosed) return;
    _didNavigate = true;
    Get.offAllNamed(Routes.login);
  }

  Future<void> _goHome() async {
    if (_didNavigate || isClosed) return;
    _didNavigate = true;
    Get.offAllNamed(Routes.home);
  }
}
