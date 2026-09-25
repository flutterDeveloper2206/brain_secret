import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/permission_action_mapping_request.dart';
import '../models/permission_action_tree_node.dart';
import '../models/permission_master_request.dart';
import '../models/permission_master_response.dart';
import '../providers/api_service.dart';
import 'permission_master_repo.dart';

class PermissionMasterRepositoryImpl implements PermissionMasterRepository {
  PermissionMasterRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  bool _isEmptyListMessage(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.contains('no permission') ||
        normalized.contains('permission not found') ||
        normalized.contains('no data found') ||
        normalized.contains('data not found') ||
        normalized.contains('not found');
  }

  PermissionMasterApiResponse _parseApiResponse(
    dynamic body,
    String fallback,
  ) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = PermissionMasterApiResponse.fromJson(
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

  @override
  Future<PermissionMasterApiResponse> createPermission(
    PermissionMasterRequest request,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.permissionCreateEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(response.body, 'Unable to create permission.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to create permission. Please try again.');
    }
  }

  @override
  Future<PermissionMasterApiResponse> updatePermission(
    PermissionMasterRequest request,
  ) async {
    try {
      _ensureToken();
      if (request.permissionCode == null || request.permissionCode! <= 0) {
        throw ServerException('Permission code is required for update.');
      }
      final response = await apiService.safePost(
        AppConstants.permissionUpdateEndpoint,
        request.toJson(includeCode: true),
      );
      return _parseApiResponse(response.body, 'Unable to update permission.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to update permission. Please try again.');
    }
  }

  @override
  Future<PermissionMasterListResponse> listPermissions() async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.permissionListEndpoint,
      );
      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected permission list response.');
      }
      final listResponse = PermissionMasterListResponse.fromJson(
        Map<String, dynamic>.from(body),
      );
      if (!listResponse.isSuccess) {
        if (_isEmptyListMessage(listResponse.message)) {
          return PermissionMasterListResponse(
            statusCode: 200,
            message: listResponse.message,
            items: const [],
          );
        }
        throw ServerException(
          listResponse.message.isEmpty
              ? 'Unable to load permissions.'
              : listResponse.message,
          statusCode: listResponse.statusCode,
        );
      }
      return listResponse;
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to load permissions. Please try again.');
    }
  }

  @override
  Future<PermissionMasterGetResponse> getPermission(int permissionCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.permissionGetEndpoint}/$permissionCode',
      );
      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected permission response.');
      }
      final getResponse = PermissionMasterGetResponse.fromJson(
        Map<String, dynamic>.from(body),
      );
      if (!getResponse.isSuccess) {
        throw ServerException(
          getResponse.message.isEmpty
              ? 'Unable to load permission.'
              : getResponse.message,
          statusCode: getResponse.statusCode,
        );
      }
      return getResponse;
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException('Unable to load permission. Please try again.');
    }
  }

  @override
  Future<PermissionDropdownResponse> getPermissionDropdown() async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.permissionDropdownEndpoint,
      );
      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected permission dropdown response.');
      }
      final dropdown = PermissionDropdownResponse.fromJson(
        Map<String, dynamic>.from(body),
      );
      if (!dropdown.isSuccess) {
        if (_isEmptyListMessage(dropdown.message)) {
          return PermissionDropdownResponse(
            statusCode: 200,
            message: dropdown.message,
            items: const [],
          );
        }
        throw ServerException(
          dropdown.message.isEmpty
              ? 'Unable to load permission dropdown.'
              : dropdown.message,
          statusCode: dropdown.statusCode,
        );
      }
      return dropdown;
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to load permission dropdown. Please try again.',
      );
    }
  }

  PermissionActionTreeResponse _parseActionTreeResponse(
    dynamic body,
    String fallback,
  ) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final tree = PermissionActionTreeResponse.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (!tree.isSuccess) {
      if (_isEmptyListMessage(tree.message)) {
        return PermissionActionTreeResponse(
          statusCode: 200,
          message: tree.message,
          nodes: const [],
        );
      }
      throw ServerException(
        tree.message.isEmpty ? fallback : tree.message,
        statusCode: tree.statusCode,
      );
    }
    return tree;
  }

  @override
  Future<PermissionActionTreeResponse> getActionsOfPermission(
    int permissionCode,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.permissionActionsOfCodeEndpoint}/$permissionCode',
      );
      return _parseActionTreeResponse(
        response.body,
        'Unable to load permission actions.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to load permission actions. Please try again.',
      );
    }
  }

  @override
  Future<PermissionActionTreeResponse> getActionTreeForPermission(
    int permissionCode,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.permissionActionTreeForEndpoint}/$permissionCode',
      );
      return _parseActionTreeResponse(
        response.body,
        'Unable to load action tree.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to load action tree. Please try again.',
      );
    }
  }

  @override
  Future<PermissionMasterApiResponse> savePermissionActions(
    PermissionActionMappingRequest request,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.permissionActionCreateEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(
        response.body,
        'Unable to save permission actions.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException(
        'Unable to save permission actions. Please try again.',
      );
    }
  }
}
