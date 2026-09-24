import 'package:get/get.dart';
import '../models/login_data_session.dart';

/// In-memory auth session after successful login.
class AuthSession extends GetxService {
  final Rxn<LoginDataSession> session = Rxn<LoginDataSession>();

  String? get token => session.value?.token;
  String? get userType => session.value?.userType;
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void save(LoginDataSession data) {
    session.value = data;
  }

  void clear() {
    session.value = null;
  }
}
