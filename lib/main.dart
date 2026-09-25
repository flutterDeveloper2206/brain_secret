import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'core/values/app_constants.dart';
import 'data/providers/api_service.dart';
import 'data/providers/local_db.dart';
import 'data/providers/native_service.dart';
import 'data/providers/permission_service.dart';
import 'data/repositories/auth_repo.dart';
import 'data/repositories/auth_repo_impl.dart';
import 'data/repositories/fingerprint_repo.dart';
import 'data/repositories/fingerprint_repo_impl.dart';
import 'data/repositories/permissions_repo.dart';
import 'data/repositories/permissions_repo_impl.dart';
import 'data/repositories/user_repo.dart';
import 'data/repositories/user_repo_impl.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localDb = LocalDb();
  await localDb.init();

  Get.put(ThemeController());
  Get.put<LocalDb>(localDb, permanent: true);
  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<NativeService>(NativeService(), permanent: true);
  Get.put<PermissionService>(
    PermissionService(localDb: localDb),
    permanent: true,
  );
  Get.put<AuthRepository>(
    AuthRepositoryImpl(apiService: Get.find<ApiService>()),
    permanent: true,
  );
  Get.put<PermissionsRepository>(
    PermissionsRepositoryImpl(apiService: Get.find<ApiService>()),
    permanent: true,
  );
  Get.put<UserRepository>(
    UserRepositoryImpl(apiService: Get.find<ApiService>()),
    permanent: true,
  );
  Get.put<FingerprintRepository>(
    FingerprintRepositoryImpl(
      nativeService: Get.find<NativeService>(),
      apiService: Get.find<ApiService>(),
    ),
    permanent: true,
  );

  runApp(const RidgeCounterApp());
}

class RidgeCounterApp extends StatelessWidget {
  const RidgeCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeController.themeMode.value,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
