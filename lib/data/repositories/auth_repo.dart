import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
}
