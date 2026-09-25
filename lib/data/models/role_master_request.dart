class RoleMasterRequest {
  const RoleMasterRequest({
    this.roleCode,
    required this.roleName,
    required this.roleDescription,
    required this.isActive,
    required this.isBlock,
  });

  final int? roleCode;
  final String roleName;
  final String roleDescription;
  final bool isActive;
  final bool isBlock;

  Map<String, dynamic> toJson({bool includeCode = false}) {
    final map = <String, dynamic>{
      'role_name': roleName,
      'role_description': roleDescription,
      'is_active': isActive,
      'is_block': isBlock,
    };
    if (includeCode && roleCode != null) {
      map['role_code'] = roleCode;
    }
    return map;
  }
}

class RolePermissionMappingRequest {
  const RolePermissionMappingRequest({
    required this.roleCode,
    required this.permissionCodes,
  });

  final int roleCode;
  final List<int> permissionCodes;

  Map<String, dynamic> toJson() {
    return {
      'role_code': roleCode,
      'permission_codes': permissionCodes,
    };
  }
}
