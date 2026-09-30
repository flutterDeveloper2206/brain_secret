class CustomerReport {
  const CustomerReport({
    required this.reportResultId,
    required this.customerId,
    required this.parentId,
    required this.reportName,
    required this.reportResult,
    required this.reportDatetime,
    this.subscribeId = 0,
    this.subscribe = false,
    this.subscribeDate,
    this.isActive = true,
    this.reportGenerate = true,
    this.regenerateDatetime,
  });

  final int reportResultId;
  final int customerId;
  final int parentId;
  final String reportName;
  final Map<String, dynamic> reportResult;
  final String reportDatetime;
  final int subscribeId;
  final bool subscribe;
  final String? subscribeDate;
  final bool isActive;
  final bool reportGenerate;
  final String? regenerateDatetime;

  factory CustomerReport.fromJson(Map<String, dynamic> json) {
    final rawResult = json['report_result'];
    final resultMap = <String, dynamic>{};
    if (rawResult is Map) {
      resultMap.addAll(Map<String, dynamic>.from(rawResult));
    }

    return CustomerReport(
      reportResultId: _asInt(json['report_result_id']),
      customerId: _asInt(json['customer_id']),
      parentId: _asInt(json['parent_id']),
      reportName: json['report_name']?.toString() ?? '',
      reportResult: resultMap,
      reportDatetime: json['report_datetime']?.toString() ?? '',
      subscribeId: _asInt(json['subscribe_id']),
      subscribe: _asBool(json['subscribe']),
      subscribeDate: json['subscribe_date']?.toString(),
      isActive: _asBool(json['is_active'] ?? true),
      reportGenerate: _asBool(json['report_generate'] ?? true),
      regenerateDatetime: json['regenerate_datetime']?.toString(),
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
