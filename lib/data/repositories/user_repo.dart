import '../models/get_user_response.dart';

abstract class UserRepository {
  Future<GetUserResponse> getCurrentUser();
}
