import 'staff.dart';

class GetAllStaffResponse {
  const GetAllStaffResponse({
    required this.statusCode,
    required this.message,
    required this.staffList,
  });

  final int statusCode;
  final String message;
  final List<Staff> staffList;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory GetAllStaffResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <Staff>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(Staff.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map) {
      final nested =
          rawData['staff'] ??
          rawData['staffList'] ??
          rawData['employees'] ??
          rawData['list'] ??
          rawData['items'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) {
            list.add(Staff.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        list.add(Staff.fromJson(Map<String, dynamic>.from(rawData)));
      }
    }

    return GetAllStaffResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      staffList: list,
    );
  }
}

class GetStaffResponse {
  const GetStaffResponse({
    required this.statusCode,
    required this.message,
    this.staff,
  });

  final int statusCode;
  final String message;
  final Staff? staff;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && staff != null;

  factory GetStaffResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Staff? staff;

    if (rawData is Map) {
      staff = Staff.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      staff = Staff.fromJson(Map<String, dynamic>.from(rawData.first as Map));
    }

    return GetStaffResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      staff: staff,
    );
  }
}
