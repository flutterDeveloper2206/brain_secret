import 'permission_master.dart';

class PermissionMasterApiResponse {
  const PermissionMasterApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final dynamic data;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory PermissionMasterApiResponse.fromJson(Map<String, dynamic> json) {
    return PermissionMasterApiResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      data: json['data'],
    );
  }
}

class PermissionMasterListResponse {
  const PermissionMasterListResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<PermissionMaster> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory PermissionMasterListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <PermissionMaster>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(PermissionMaster.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map) {
      final nested =
          rawData['permissions'] ??
          rawData['permissionList'] ??
          rawData['list'] ??
          rawData['items'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) {
            list.add(
              PermissionMaster.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
    }

    return PermissionMasterListResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}

class PermissionMasterGetResponse {
  const PermissionMasterGetResponse({
    required this.statusCode,
    required this.message,
    this.permission,
  });

  final int statusCode;
  final String message;
  final PermissionMaster? permission;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && permission != null;

  factory PermissionMasterGetResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    PermissionMaster? permission;

    if (rawData is Map) {
      permission = PermissionMaster.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    } else if (rawData is List &&
        rawData.isNotEmpty &&
        rawData.first is Map) {
      permission = PermissionMaster.fromJson(
        Map<String, dynamic>.from(rawData.first as Map),
      );
    }

    return PermissionMasterGetResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      permission: permission,
    );
  }
}

class PermissionDropdownItem {
  const PermissionDropdownItem({
    required this.permissionCode,
    required this.permissionName,
  });

  final int permissionCode;
  final String permissionName;

  factory PermissionDropdownItem.fromJson(Map<String, dynamic> json) {
    return PermissionDropdownItem(
      permissionCode: _asInt(
        json['id'] ??
            json['permission_code'] ??
            json['permissionCode'] ??
            json['value'],
      ),
      permissionName:
          json['permission_name']?.toString() ??
          json['permissionName']?.toString() ??
          json['value']?.toString() ??
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

class PermissionDropdownResponse {
  const PermissionDropdownResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<PermissionDropdownItem> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory PermissionDropdownResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <PermissionDropdownItem>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(
            PermissionDropdownItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return PermissionDropdownResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}
