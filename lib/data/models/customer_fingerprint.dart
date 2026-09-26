class CustomerFingerprint {
  const CustomerFingerprint({
    required this.fingerprintId,
    required this.customerId,
    required this.parentId,
    required this.entryDate,
    required this.fingerName,
    required this.fingerImageName,
    required this.fingerImageUrl,
    required this.fingerValue,
    this.fingerType,
    this.isActive = true,
  });

  final int fingerprintId;
  final int customerId;
  final int parentId;
  final String entryDate;
  final String fingerName;
  final String fingerImageName;
  final String fingerImageUrl;
  final int fingerValue;
  final String? fingerType;
  final bool isActive;

  factory CustomerFingerprint.fromJson(Map<String, dynamic> json) {
    return CustomerFingerprint(
      fingerprintId: _asInt(json['fingerprint_id'] ?? json['fingerprintId']),
      customerId: _asInt(json['customer_id'] ?? json['customerId']),
      parentId: _asInt(json['parent_id'] ?? json['parentId']),
      entryDate: json['entry_date']?.toString() ?? '',
      fingerName: json['finger_name']?.toString() ?? '',
      fingerImageName: json['finger_image_name']?.toString() ?? '',
      fingerImageUrl: json['finger_image_url']?.toString() ?? '',
      fingerValue: _asInt(json['finger_value'] ?? json['fingerValue']),
      fingerType: json['finger_type']?.toString(),
      isActive: _asBool(json['is_active'] ?? json['isActive'] ?? true),
    );
  }

  CustomerFingerprint copyWith({
    int? fingerprintId,
    int? customerId,
    int? parentId,
    String? entryDate,
    String? fingerName,
    String? fingerImageName,
    String? fingerImageUrl,
    int? fingerValue,
    String? fingerType,
    bool? isActive,
  }) {
    return CustomerFingerprint(
      fingerprintId: fingerprintId ?? this.fingerprintId,
      customerId: customerId ?? this.customerId,
      parentId: parentId ?? this.parentId,
      entryDate: entryDate ?? this.entryDate,
      fingerName: fingerName ?? this.fingerName,
      fingerImageName: fingerImageName ?? this.fingerImageName,
      fingerImageUrl: fingerImageUrl ?? this.fingerImageUrl,
      fingerValue: fingerValue ?? this.fingerValue,
      fingerType: fingerType ?? this.fingerType,
      isActive: isActive ?? this.isActive,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}
