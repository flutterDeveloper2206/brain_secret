import 'permission_node.dart';

class PermissionsResponse {
  const PermissionsResponse({
    required this.statusCode,
    required this.message,
    required this.sideBar,
    this.rawData,
  });

  final int statusCode;
  final String message;
  final List<PermissionNode> sideBar;
  final Map<String, dynamic>? rawData;

  bool get isSuccess => statusCode == 200;

  factory PermissionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final sideBarRaw =
        dataMap?['sideBar'] ?? dataMap?['SideBar'] ?? dataMap?['sidebar'];

    final statusRaw =
        json['statusCode'] ?? json['StatusCode'] ?? json['status_code'];
    int statusCode = 0;
    if (statusRaw is int) {
      statusCode = statusRaw;
    } else if (statusRaw is num) {
      statusCode = statusRaw.toInt();
    } else {
      statusCode = int.tryParse(statusRaw?.toString() ?? '') ?? 0;
    }

    return PermissionsResponse(
      statusCode: statusCode,
      message: json['message']?.toString() ??
          json['Message']?.toString() ??
          'Unknown response',
      sideBar: sideBarRaw is List
          ? sideBarRaw
                .whereType<Map>()
                .map(
                  (e) => PermissionNode.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      rawData: dataMap,
    );
  }
}
