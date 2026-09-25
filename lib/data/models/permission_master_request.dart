class PermissionMasterRequest {
  const PermissionMasterRequest({
    this.permissionCode,
    required this.permissionName,
    required this.permissionDescription,
    required this.isActive,
    required this.isBlock,
  });

  final int? permissionCode;
  final String permissionName;
  final String permissionDescription;
  final bool isActive;
  final bool isBlock;

  Map<String, dynamic> toJson({bool includeCode = false}) {
    final map = <String, dynamic>{
      'permission_name': permissionName,
      'permission_description': permissionDescription,
      'is_active': isActive,
      'is_block': isBlock,
    };
    if (includeCode && permissionCode != null) {
      map['permission_code'] = permissionCode;
    }
    return map;
  }
}
