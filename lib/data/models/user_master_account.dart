class UserMasterAccount {
  const UserMasterAccount({
    required this.id,
    required this.displayName,
    required this.userType,
    this.email,
    this.mobile,
    this.subtitle,
    this.parentId = 0,
    this.companyCode = 0,
    this.franchiseCode = 0,
    this.raw = const {},
  });

  /// customer_id / franchise_code / employee_id
  final int id;
  final String displayName;
  final String userType;
  final String? email;
  final String? mobile;
  final String? subtitle;
  final int parentId;
  final int companyCode;
  final int franchiseCode;
  final Map<String, dynamic> raw;

  bool get isFamilyMember => parentId > 0;

  factory UserMasterAccount.fromJson(
    String userType,
    Map<String, dynamic> json,
  ) {
    final type = userType.trim().toUpperCase();
    switch (type) {
      case 'FRANCHISE':
        return UserMasterAccount(
          id: _asInt(json['franchise_code'] ?? json['id']),
          displayName: _string(
            json['franchise_name'] ?? json['value'] ?? json['full_name'],
          ),
          userType: type,
          email: _nullable(json['email_id']),
          mobile: _nullable(json['mobile_no']),
          subtitle: _nullable(json['city']) ?? _nullable(json['owner_name']),
          companyCode: _asInt(json['company_code']),
          franchiseCode: _asInt(json['franchise_code'] ?? json['id']),
          raw: Map<String, dynamic>.from(json),
        );
      case 'STAFF':
        return UserMasterAccount(
          id: _asInt(json['employee_id'] ?? json['id']),
          displayName: _string(
            json['employee_full_name'] ?? json['full_name'] ?? json['value'],
          ),
          userType: type,
          email: _nullable(json['email_id']),
          mobile: _nullable(json['mobile_no']),
          subtitle: [
            _nullable(json['designation_name']),
            _nullable(json['department_name']),
          ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
          companyCode: _asInt(json['company_code']),
          raw: Map<String, dynamic>.from(json),
        );
      case 'CUSTOMER':
      default:
        return UserMasterAccount(
          id: _asInt(json['customer_id'] ?? json['id']),
          displayName: _string(
            json['customer_full_name'] ?? json['full_name'] ?? json['value'],
          ),
          userType: type.isEmpty ? 'CUSTOMER' : type,
          email: _nullable(json['email_id']),
          mobile: _nullable(json['mobile_no']),
          subtitle: _nullable(json['city_name']) ??
              _nullable(json['occupation']),
          parentId: _asInt(json['parent_id']),
          companyCode: _asInt(json['company_code']),
          franchiseCode: _asInt(json['franchise_code']),
          raw: Map<String, dynamic>.from(json),
        );
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _string(dynamic value) {
    return _nullable(value) ?? '';
  }

  static String? _nullable(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
