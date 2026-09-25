import '../models/permission_action_mapping_request.dart';
import '../models/permission_action_tree_node.dart';
import '../models/permission_master_request.dart';
import '../models/permission_master_response.dart';

abstract class PermissionMasterRepository {
  Future<PermissionMasterApiResponse> createPermission(
    PermissionMasterRequest request,
  );

  Future<PermissionMasterApiResponse> updatePermission(
    PermissionMasterRequest request,
  );

  Future<PermissionMasterListResponse> listPermissions();

  Future<PermissionMasterGetResponse> getPermission(int permissionCode);

  Future<PermissionDropdownResponse> getPermissionDropdown();

  Future<PermissionActionTreeResponse> getActionsOfPermission(
    int permissionCode,
  );

  /// GET rightsmaster/get/action/tree/for/{permissionId}
  Future<PermissionActionTreeResponse> getActionTreeForPermission(
    int permissionCode,
  );

  Future<PermissionMasterApiResponse> savePermissionActions(
    PermissionActionMappingRequest request,
  );
}
