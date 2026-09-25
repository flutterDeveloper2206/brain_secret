import 'user_profile.dart';

class GetUserResponse {
  const GetUserResponse({
    required this.statusCode,
    required this.message,
    this.user,
  });

  final int statusCode;
  final String message;
  final UserProfile? user;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && user != null;

  factory GetUserResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    UserProfile? user;

    if (rawData is Map) {
      user = UserProfile.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      user = UserProfile.fromJson(
        Map<String, dynamic>.from(rawData.first as Map),
      );
    }

    return GetUserResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      user: user,
    );
  }
}
