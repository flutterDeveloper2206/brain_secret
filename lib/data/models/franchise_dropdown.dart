class FranchiseDropdownItem {
  const FranchiseDropdownItem({
    required this.franchiseCode,
    required this.franchiseName,
  });

  final int franchiseCode;
  final String franchiseName;

  factory FranchiseDropdownItem.fromJson(Map<String, dynamic> json) {
    // API shape is often `{ id, value }` where value is the display name.
    final rawValue = json['value'];
    final valueAsCode = rawValue is num ||
            (rawValue is String && int.tryParse(rawValue.trim()) != null)
        ? rawValue
        : null;

    return FranchiseDropdownItem(
      franchiseCode: _asInt(
        json['franchise_code'] ??
            json['id'] ??
            json['code'] ??
            valueAsCode,
      ),
      franchiseName: json['franchise_name']?.toString() ??
          json['label']?.toString() ??
          json['name']?.toString() ??
          json['text']?.toString() ??
          (valueAsCode == null ? (rawValue?.toString() ?? '') : ''),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class FranchiseDropdownResponse {
  const FranchiseDropdownResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<FranchiseDropdownItem> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory FranchiseDropdownResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <FranchiseDropdownItem>[];

    void addFrom(dynamic item) {
      if (item is Map) {
        list.add(FranchiseDropdownItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    if (rawData is List) {
      for (final item in rawData) {
        addFrom(item);
      }
    } else if (rawData is Map) {
      final nested =
          rawData['franchises'] ??
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

    return FranchiseDropdownResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}
