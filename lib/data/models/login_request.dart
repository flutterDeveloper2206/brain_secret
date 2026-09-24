class LoginRequest {
  const LoginRequest({
    required this.userName,
    required this.password,
    required this.deviceType,
    required this.deviceId,
    required this.fcmToken,
    required this.appVersion,
  });

  final String userName;
  final String password;
  final String deviceType;
  final String deviceId;
  final String fcmToken;
  final String appVersion;

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
      'device_type': deviceType,
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'app_version': appVersion,
    };
  }
}
