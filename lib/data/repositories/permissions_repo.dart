import '../models/permissions_response.dart';

abstract class PermissionsRepository {
  Future<PermissionsResponse> fetchUserPermissions();
}
