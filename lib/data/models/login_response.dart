class LoginResponse {
  const LoginResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final LoginData? data;

  bool get isSuccess => statusCode == 200 && data != null;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return LoginResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      data: rawData is Map<String, dynamic>
          ? LoginData.fromJson(rawData)
          : null,
    );
  }
}

class LoginData {
  const LoginData({
    required this.token,
    required this.expiresAt,
    required this.userType,
  });

  final String token;
  final String expiresAt;
  final String userType;

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
    );
  }
}
