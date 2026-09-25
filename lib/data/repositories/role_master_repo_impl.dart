import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/role_master_request.dart';
import '../models/role_master_response.dart';
import '../providers/api_service.dart';
import 'role_master_repo.dart';

class RoleMasterRepositoryImpl implements RoleMasterRepository {
  RoleMasterRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  bool _isEmptyListMessage(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.contains('no role') ||
        normalized.contains('role not found') ||
        normalized.contains('no permission') ||
        normalized.contains('permission not found') ||
        normalized.contains('no data found') ||
        normalized.contains('data not found') ||
        normalized.contains('not found');
  }

  RoleMasterApiResponse _parseApiResponse(dynamic body, String fallback) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = RoleMasterApiResponse.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (!response.isSuccess) {
      throw ServerException(
        response.message.isEmpty ? fallback : response.message,
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  RolePermissionListResponse _parsePermissionList(
    dynamic body,
    String fallback,
  ) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = RolePermissionListResponse.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (!response.isSuccess) {
      if (_isEmptyListMessage(response.message)) {
        return RolePermissionListResponse(
          statusCode: 200,
          message: response.message,
          items: const [],
        );
      }
      throw ServerException(
        response.message.isEmpty ? fallback : response.message,
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<RoleMasterApiResponse> createRole(RoleMasterRequest request) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.roleCreateEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(response.body, 'Unable to create role.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to create role. Please try again.');
    }
  }

  @override
  Future<RoleMasterApiResponse> updateRole(RoleMasterRequest request) async {
    try {
      _ensureToken();
      if (request.roleCode == null || request.roleCode! <= 0) {
        throw ServerException('Role code is required for update.');
      }
      final response = await apiService.safePost(
        AppConstants.roleUpdateEndpoint,
        request.toJson(includeCode: true),
      );
      return _parseApiResponse(response.body, 'Unable to update role.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to update role. Please try again.');
    }
  }

  @override
  Future<RoleMasterListResponse> listRoles() async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(AppConstants.roleListEndpoint);
      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected role list response.');
      }
      final listResponse = RoleMasterListResponse.fromJson(
        Map<String, dynamic>.from(body),
      );
      if (!listResponse.isSuccess) {
        if (_isEmptyListMessage(listResponse.message)) {
          return RoleMasterListResponse(
            statusCode: 200,
            message: listResponse.message,
            items: const [],
          );
        }
        throw ServerException(
          listResponse.message.isEmpty
              ? 'Unable to load roles.'
              : listResponse.message,
          statusCode: listResponse.statusCode,
        );
      }
      return listResponse;
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to load roles. Please try again.');
    }
  }

  @override
  Future<RoleMasterGetResponse> getRole(int roleCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.roleGetEndpoint}/$roleCode',
      );
      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected role response.');
      }
      final getResponse = RoleMasterGetResponse.fromJson(
        Map<String, dynamic>.from(body),
      );
      if (!getResponse.isSuccess) {
        throw ServerException(
          getResponse.message.isEmpty
              ? 'Unable to load role.'
              : getResponse.message,
          statusCode: getResponse.statusCode,
        );
      }
      return getResponse;
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to load role. Please try again.');
    }
  }

  @override
  Future<RolePermissionListResponse> getRolePermissions(int roleCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.rolePermissionsEndpoint}/$roleCode',
      );
      return _parsePermissionList(
        response.body,
        'Unable to load role permissions.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to load role permissions. Please try again.',
      );
    }
  }

  @override
  Future<RolePermissionListResponse> getPermissionsOfRole(int roleCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.permissionsOfRoleCodeEndpoint}/$roleCode',
      );
      return _parsePermissionList(
        response.body,
        'Unable to load permissions for role.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to load permissions for role. Please try again.',
      );
    }
  }

  @override
  Future<RoleMasterApiResponse> saveRolePermissions(
    RolePermissionMappingRequest request,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.rolePermissionCreateEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(
        response.body,
        'Unable to save role permissions.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to save role permissions. Please try again.',
      );
    }
  }
}
