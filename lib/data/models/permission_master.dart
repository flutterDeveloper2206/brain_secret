class PermissionMaster {
  const PermissionMaster({
    required this.permissionCode,
    required this.permissionName,
    required this.permissionDescription,
    required this.isActive,
    required this.isBlock,
    this.isChecked = false,
  });

  final int permissionCode;
  final String permissionName;
  final String permissionDescription;
  final bool isActive;
  final bool isBlock;
  final bool isChecked;

  factory PermissionMaster.fromJson(Map<String, dynamic> json) {
    return PermissionMaster(
      permissionCode: _asInt(
        json['permission_code'] ?? json['permissionCode'] ?? json['id'],
      ),
      permissionName:
          json['permission_name']?.toString() ??
          json['permissionName']?.toString() ??
          '',
      permissionDescription:
          json['permission_description']?.toString() ??
          json['permissionDescription']?.toString() ??
          '',
      isActive: _asBool(json['is_active'] ?? json['isActive'], true),
      isBlock: _asBool(json['is_block'] ?? json['isBlock'], false),
      isChecked: _asBool(json['is_checked'] ?? json['isChecked'], false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permission_code': permissionCode,
      'permission_name': permissionName,
      'permission_description': permissionDescription,
      'is_active': isActive,
      'is_block': isBlock,
      'is_checked': isChecked,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }
}
