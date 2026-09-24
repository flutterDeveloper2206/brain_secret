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
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final sideBarRaw = dataMap?['sideBar'];

    return PermissionsResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
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
