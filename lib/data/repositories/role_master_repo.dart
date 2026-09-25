import '../models/role_master_request.dart';
import '../models/role_master_response.dart';

abstract class RoleMasterRepository {
  Future<RoleMasterApiResponse> createRole(RoleMasterRequest request);

  Future<RoleMasterApiResponse> updateRole(RoleMasterRequest request);

  Future<RoleMasterListResponse> listRoles();

  Future<RoleMasterGetResponse> getRole(int roleCode);

  /// GET rightsmaster/role/permissions/{roleCode}
  Future<RolePermissionListResponse> getRolePermissions(int roleCode);

  /// GET rightsmaster/permission/of/role/code/{roleCode}
  Future<RolePermissionListResponse> getPermissionsOfRole(int roleCode);

  Future<RoleMasterApiResponse> saveRolePermissions(
    RolePermissionMappingRequest request,
  );
}
