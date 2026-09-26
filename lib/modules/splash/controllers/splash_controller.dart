import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController({
    required this.apiService,
    required this.permissionService,
    required this.userRepository,
  });

  final ApiService apiService;
  final PermissionService permissionService;
  final UserRepository userRepository;

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
      // Unexpected bootstrap failure: if we already have a token, still go home.
      final token = permissionService.token;
      if (token != null && token.isNotEmpty) {
        apiService.setAuthToken(token);
        await _goHome();
        return;
      }
      ErrorHandler.handleError(e, forceLogout: false);
      await _goLogin();
    }
  }

  Future<void> _resolveSession() async {
    // Restore session + cached permissions from local storage only.
    // Permissions API is fetched only after successful login.
    await permissionService.hydrateFromLocal();
    final token = permissionService.token;

    if (token == null || token.isEmpty) {
      await _goLogin();
      return;
    }

    apiService.setAuthToken(token);

    // Non-blocking profile refresh for dashboard (not persisted).
    try {
      final userResponse = await userRepository.getCurrentUser();
      await permissionService.setUserProfile(userResponse.user);
    } catch (_) {
      permissionService.clearUserProfile();
    }

    await _goHome();
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
