import 'permission_master.dart';
import 'role_master.dart';

class RoleMasterApiResponse {
  const RoleMasterApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final dynamic data;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory RoleMasterApiResponse.fromJson(Map<String, dynamic> json) {
    return RoleMasterApiResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      data: json['data'],
    );
  }
}

class RoleMasterListResponse {
  const RoleMasterListResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<RoleMaster> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory RoleMasterListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <RoleMaster>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(RoleMaster.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map) {
      final nested =
          rawData['roles'] ??
          rawData['roleList'] ??
          rawData['list'] ??
          rawData['items'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) {
            list.add(RoleMaster.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    }

    return RoleMasterListResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}

class RoleMasterGetResponse {
  const RoleMasterGetResponse({
    required this.statusCode,
    required this.message,
    this.role,
  });

  final int statusCode;
  final String message;
  final RoleMaster? role;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && role != null;

  factory RoleMasterGetResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    RoleMaster? role;

    if (rawData is Map) {
      role = RoleMaster.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List &&
        rawData.isNotEmpty &&
        rawData.first is Map) {
      role = RoleMaster.fromJson(
        Map<String, dynamic>.from(rawData.first as Map),
      );
    }

    return RoleMasterGetResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      role: role,
    );
  }
}

/// Permissions returned for a role (with optional isChecked autofill).
class RolePermissionListResponse {
  const RolePermissionListResponse({
    required this.statusCode,
    required this.message,
    required this.items,
  });

  final int statusCode;
  final String message;
  final List<PermissionMaster> items;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory RolePermissionListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <PermissionMaster>[];

    void addFrom(dynamic item) {
      if (item is Map) {
        list.add(PermissionMaster.fromJson(Map<String, dynamic>.from(item)));
      } else if (item is num || item is String) {
        final code = int.tryParse(item.toString()) ?? 0;
        if (code > 0) {
          list.add(
            PermissionMaster(
              permissionCode: code,
              permissionName: 'Permission #$code',
              permissionDescription: '',
              isActive: true,
              isBlock: false,
              isChecked: true,
            ),
          );
        }
      }
    }

    if (rawData is List) {
      for (final item in rawData) {
        addFrom(item);
      }
    } else if (rawData is Map) {
      final nested =
          rawData['permissions'] ??
          rawData['permissionList'] ??
          rawData['list'] ??
          rawData['items'] ??
          rawData['permission_codes'] ??
          rawData['permissionCodes'];
      if (nested is List) {
        for (final item in nested) {
          addFrom(item);
        }
      }
    }

    return RolePermissionListResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      items: list,
    );
  }
}
