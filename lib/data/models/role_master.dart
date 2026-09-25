class RoleMaster {
  const RoleMaster({
    required this.roleCode,
    required this.roleName,
    required this.roleDescription,
    required this.isActive,
    required this.isBlock,
  });

  final int roleCode;
  final String roleName;
  final String roleDescription;
  final bool isActive;
  final bool isBlock;

  factory RoleMaster.fromJson(Map<String, dynamic> json) {
    return RoleMaster(
      roleCode: _asInt(json['role_code'] ?? json['roleCode'] ?? json['id']),
      roleName:
          json['role_name']?.toString() ?? json['roleName']?.toString() ?? '',
      roleDescription:
          json['role_description']?.toString() ??
          json['roleDescription']?.toString() ??
          '',
      isActive: _asBool(json['is_active'] ?? json['isActive'], true),
      isBlock: _asBool(json['is_block'] ?? json['isBlock'], false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_code': roleCode,
      'role_name': roleName,
      'role_description': roleDescription,
      'is_active': isActive,
      'is_block': isBlock,
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
