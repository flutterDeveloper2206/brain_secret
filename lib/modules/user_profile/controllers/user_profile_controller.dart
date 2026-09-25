import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/providers/permission_service.dart';
import '../../../data/repositories/user_repo.dart';

class UserProfileController extends GetxController {
  UserProfileController({
    required this.userRepository,
    required this.permissionService,
  });

  final UserRepository userRepository;
  final PermissionService permissionService;

  final RxBool isLoading = false.obs;
  final Rxn<UserProfile> profile = Rxn<UserProfile>();

  @override
  void onInit() {
    super.onInit();
    // Use cached profile from login/splash/dashboard — do not refetch on open.
    final cached = permissionService.userProfile.value;
    profile.value = cached;
    if (cached == null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await userRepository.getCurrentUser();
      profile.value = response.user;
      permissionService.setUserProfile(response.user);
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
