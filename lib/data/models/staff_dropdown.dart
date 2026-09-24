class StaffDropdownItem {
  const StaffDropdownItem({
    required this.employeeId,
    required this.employeeName,
  });

  final int employeeId;
  final String employeeName;

  factory StaffDropdownItem.fromJson(Map<String, dynamic> json) {
    return StaffDropdownItem(
      employeeId: _asInt(json['id'] ?? json['employee_id'] ?? json['value']),
      employeeName:
          json['value']?.toString() ??
          json['employee_full_name']?.toString() ??
          '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class StaffDropdownResponse {
  const StaffDropdownResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<StaffDropdownItem> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory StaffDropdownResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <StaffDropdownItem>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(StaffDropdownItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return StaffDropdownResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}
