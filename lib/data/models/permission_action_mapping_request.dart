class PermissionActionMappingRequest {
  const PermissionActionMappingRequest({
    required this.permissionCode,
    required this.actionCodes,
  });

  final String permissionCode;
  final List<int> actionCodes;

  Map<String, dynamic> toJson() {
    return {
      'permission_code': permissionCode,
      'action_codes': actionCodes,
    };
  }
}
