import 'franchise.dart';

class GetAllFranchisesResponse {
  const GetAllFranchisesResponse({
    required this.statusCode,
    required this.message,
    required this.franchises,
  });

  final int statusCode;
  final String message;
  final List<Franchise> franchises;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory GetAllFranchisesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <Franchise>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(Franchise.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map) {
      final nested =
          rawData['franchises'] ??
          rawData['franchiseList'] ??
          rawData['list'] ??
          rawData['items'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) {
            list.add(Franchise.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        list.add(Franchise.fromJson(Map<String, dynamic>.from(rawData)));
      }
    }

    return GetAllFranchisesResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      franchises: list,
    );
  }
}

class GetFranchiseResponse {
  const GetFranchiseResponse({
    required this.statusCode,
    required this.message,
    this.franchise,
  });

  final int statusCode;
  final String message;
  final Franchise? franchise;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && franchise != null;

  factory GetFranchiseResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Franchise? franchise;

    if (rawData is Map) {
      franchise = Franchise.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      franchise = Franchise.fromJson(
        Map<String, dynamic>.from(rawData.first as Map),
      );
    }

    return GetFranchiseResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      franchise: franchise,
    );
  }
}
