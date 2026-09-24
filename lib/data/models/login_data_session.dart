class LoginDataSession {
  const LoginDataSession({
    required this.token,
    required this.expiresAt,
    required this.userType,
  });

  final String token;
  final String expiresAt;
  final String userType;
}
