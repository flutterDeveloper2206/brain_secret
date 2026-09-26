import 'package:get/get.dart';
import '../models/login_data_session.dart';
import '../models/permission_node.dart';
import '../models/permissions_response.dart';
import '../models/user_master_account.dart';
import '../models/user_profile.dart';
import 'local_db.dart';

/// In-memory permission/session state backed by SQLite.
class PermissionService extends GetxService {
  PermissionService({required this.localDb});

  final LocalDb localDb;

  final Rxn<LoginDataSession> session = Rxn<LoginDataSession>();
  final Rxn<UserProfile> userProfile = Rxn<UserProfile>();
  final RxnInt activeAccountId = RxnInt();
  final RxList<PermissionNode> sideBar = <PermissionNode>[].obs;
  final RxSet<int> actionCodes = <int>{}.obs;
  final RxSet<String> routes = <String>{}.obs;

  bool get hasToken {
    final token = session.value?.token;
    return token != null && token.isNotEmpty;
  }

  String? get token => session.value?.token;

  UserMasterAccount? get activeAccount {
    final profile = userProfile.value;
    final id = activeAccountId.value;
    if (profile == null || id == null) return null;
    for (final account in profile.accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

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

    final savedAccountId = await localDb.getActiveMasterAccountId();
    if (savedAccountId != null) {
      activeAccountId.value = savedAccountId;
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

  Future<void> setUserProfile(UserProfile? profile) async {
    userProfile.value = profile;
    if (profile == null) {
      activeAccountId.value = null;
      await localDb.clearActiveMasterAccountId();
      return;
    }
    await _resolveActiveAccount(profile);
  }

  Future<void> setActiveAccount(int id) async {
    final profile = userProfile.value;
    if (profile == null) return;
    final exists = profile.accounts.any((a) => a.id == id);
    if (!exists) return;
    activeAccountId.value = id;
    await localDb.saveActiveMasterAccountId(id);
  }

  Future<void> _resolveActiveAccount(UserProfile profile) async {
    final accounts = profile.accounts;
    if (accounts.isEmpty) {
      activeAccountId.value = null;
      await localDb.clearActiveMasterAccountId();
      return;
    }

    final saved = await localDb.getActiveMasterAccountId();
    if (saved != null && accounts.any((a) => a.id == saved)) {
      activeAccountId.value = saved;
      return;
    }

    final fallback = profile.defaultAccountId ?? accounts.first.id;
    activeAccountId.value = fallback;
    await localDb.saveActiveMasterAccountId(fallback);
  }

  void clearUserProfile() {
    userProfile.value = null;
    activeAccountId.value = null;
  }

  Future<void> clearAll() async {
    session.value = null;
    userProfile.value = null;
    activeAccountId.value = null;
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
