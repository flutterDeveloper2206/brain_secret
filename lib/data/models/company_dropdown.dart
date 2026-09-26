class CompanyDropdownItem {
  const CompanyDropdownItem({
    required this.id,
    required this.value,
  });

  final int id;
  final String value;

  factory CompanyDropdownItem.fromJson(Map<String, dynamic> json) {
    return CompanyDropdownItem(
      id: _asInt(json['id'] ?? json['company_code'] ?? json['code']),
      value: json['value']?.toString() ??
          json['company_name']?.toString() ??
          json['name']?.toString() ??
          json['label']?.toString() ??
          '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CompanyDropdownResponse {
  const CompanyDropdownResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<CompanyDropdownItem> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory CompanyDropdownResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <CompanyDropdownItem>[];

    void addFrom(dynamic item) {
      if (item is Map) {
        list.add(CompanyDropdownItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    if (rawData is List) {
      for (final item in rawData) {
        addFrom(item);
      }
    } else if (rawData is Map) {
      final nested = rawData['companies'] ??
          rawData['dropdown'] ??
          rawData['list'] ??
          rawData['items'] ??
          rawData['data'];
      if (nested is List) {
        for (final item in nested) {
          addFrom(item);
        }
      } else {
        addFrom(rawData);
      }
    }

    return CompanyDropdownResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}
