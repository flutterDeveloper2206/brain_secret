import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../providers/api_service.dart';
import 'auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await apiService.safePost(
        AppConstants.loginEndpoint,
        request.toJson(),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected login response from server.');
      }

      final loginResponse = LoginResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!loginResponse.isSuccess) {
        throw ServerException(
          loginResponse.message.isEmpty
              ? 'Login failed. Please try again.'
              : loginResponse.message,
        );
      }

      return loginResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to complete login. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = apiService.authToken;
      if (token == null || token.isEmpty) {
        throw ServerException('Authentication token is missing.');
      }

      await apiService.safeGet(AppConstants.logoutEndpoint);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to logout. Please try again.');
    }
  }
}
