import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/get_user_response.dart';
import '../providers/api_service.dart';
import 'user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  @override
  Future<GetUserResponse> getCurrentUser() async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.userProfileEndpoint,
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected user profile response from server.');
      }

      final parsed = GetUserResponse.fromJson(Map<String, dynamic>.from(body));
      if (!parsed.isSuccess) {
        throw ServerException(
          parsed.message.isEmpty
              ? 'Unable to load user profile.'
              : parsed.message,
        );
      }

      return parsed;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load user profile. Please try again.');
    }
  }
}
