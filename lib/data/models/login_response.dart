class LoginResponse {
  const LoginResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final LoginData? data;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) &&
      data != null &&
      data!.token.isNotEmpty;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    LoginData? data;
    if (rawData is Map) {
      data = LoginData.fromJson(Map<String, dynamic>.from(rawData));
    }

    final statusRaw = json['statusCode'] ?? json['StatusCode'] ?? json['status_code'];
    int statusCode = 0;
    if (statusRaw is int) {
      statusCode = statusRaw;
    } else if (statusRaw is num) {
      statusCode = statusRaw.toInt();
    } else {
      statusCode = int.tryParse(statusRaw?.toString() ?? '') ?? 0;
    }

    return LoginResponse(
      statusCode: statusCode,
      message: json['message']?.toString() ??
          json['Message']?.toString() ??
          'Unknown response',
      data: data,
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
      token: json['token']?.toString() ??
          json['Token']?.toString() ??
          json['access_token']?.toString() ??
          json['accessToken']?.toString() ??
          '',
      expiresAt: json['expiresAt']?.toString() ??
          json['ExpiresAt']?.toString() ??
          json['expires_at']?.toString() ??
          '',
      userType: json['userType']?.toString() ??
          json['UserType']?.toString() ??
          json['user_type']?.toString() ??
          '',
    );
  }
}
