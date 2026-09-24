import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/permissions_response.dart';
import '../providers/api_service.dart';
import 'permissions_repo.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  PermissionsRepositoryImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<PermissionsResponse> fetchUserPermissions() async {
    try {
      final token = apiService.authToken;
      if (token == null || token.isEmpty) {
        throw ServerException('Authentication token is missing.');
      }

      final response = await apiService.safeGet(
        AppConstants.permissionsEndpoint,
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected permissions response from server.');
      }

      final permissions = PermissionsResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!permissions.isSuccess) {
        throw ServerException(
          permissions.message.isEmpty
              ? 'Unable to load permissions.'
              : permissions.message,
        );
      }

      return permissions;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load user permissions. Please try again.');
    }
  }
}
