import 'package:get/get.dart';
import '../models/login_data_session.dart';
import '../models/permission_node.dart';
import '../models/permissions_response.dart';
import '../models/user_profile.dart';
import 'local_db.dart';

/// In-memory permission/session state backed by SQLite.
class PermissionService extends GetxService {
  PermissionService({required this.localDb});

  final LocalDb localDb;

  final Rxn<LoginDataSession> session = Rxn<LoginDataSession>();
  final Rxn<UserProfile> userProfile = Rxn<UserProfile>();
  final RxList<PermissionNode> sideBar = <PermissionNode>[].obs;
  final RxSet<int> actionCodes = <int>{}.obs;
  final RxSet<String> routes = <String>{}.obs;

  bool get hasToken {
    final token = session.value?.token;
    return token != null && token.isNotEmpty;
  }

  String? get token => session.value?.token;

  bool hasAction(int actionCode) => actionCodes.contains(actionCode);

  bool hasRoute(String route) {
    if (route.isEmpty || route == '#') return false;
    return routes.contains(route);
  }

  Future<void> hydrateFromLocal() async {
    final savedSession = await localDb.getSession();
    session.value = savedSession;

    final payload = await localDb.getPermissionsPayload();
    if (payload != null) {
      _applyPayload(payload);
    }
  }

  Future<void> saveSession(LoginDataSession data) async {
    session.value = data;
    await localDb.saveSession(data);
  }

  Future<void> applyPermissions(PermissionsResponse response) async {
    final payload = response.rawData ??
        {
          'sideBar': response.sideBar.map((e) => e.toJson()).toList(),
        };
    await localDb.savePermissionsPayload(payload);
    _applyPayload(payload);
  }

  void setUserProfile(UserProfile? profile) {
    userProfile.value = profile;
  }

  void clearUserProfile() {
    userProfile.value = null;
  }

  Future<void> clearAll() async {
    session.value = null;
    userProfile.value = null;
    sideBar.clear();
    actionCodes.clear();
    routes.clear();
    await localDb.clearAll();
  }

  void _applyPayload(Map<String, dynamic> payload) {
    final sideBarRaw = payload['sideBar'];
    final nodes = sideBarRaw is List
        ? sideBarRaw
            .whereType<Map>()
            .map((e) => PermissionNode.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <PermissionNode>[];

    sideBar.assignAll(nodes);

    final codes = <int>{};
    final routeSet = <String>{};
    void walk(PermissionNode node) {
      if (node.actionCode != 0) codes.add(node.actionCode);
      if (node.route.isNotEmpty && node.route != '#') {
        routeSet.add(node.route);
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final node in nodes) {
      walk(node);
    }
    actionCodes
      ..clear()
      ..addAll(codes);
    routes
      ..clear()
      ..addAll(routeSet);
  }
}
