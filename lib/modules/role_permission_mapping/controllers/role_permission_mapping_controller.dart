import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/permission_master.dart';
import '../../../data/models/role_master_request.dart';
import '../../../data/repositories/permission_master_repo.dart';
import '../../../data/repositories/role_master_repo.dart';

class RolePermissionMappingController extends GetxController {
  RolePermissionMappingController({
    required this.roleRepository,
    required this.permissionRepository,
  });

  final RoleMasterRepository roleRepository;
  final PermissionMasterRepository permissionRepository;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<PermissionMaster> permissions = <PermissionMaster>[].obs;
  final RxList<int> selectedPermissionCodes = <int>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectionVersion = 0.obs;

  final searchController = TextEditingController();

  late final int roleCode;
  late final String roleName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      roleCode = _asInt(args['roleCode']);
      roleName = args['roleName']?.toString() ?? '';
    } else if (args is int) {
      roleCode = args;
      roleName = '';
    } else {
      roleCode = 0;
      roleName = '';
    }
    loadPermissions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    if (isClosed) return;
    searchQuery.value = value;
  }

  List<PermissionMaster> get visiblePermissions {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return permissions.toList();
    return permissions.where((item) {
      final haystack = [
        item.permissionCode.toString(),
        item.permissionName,
        item.permissionDescription,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> loadPermissions() async {
    if (isClosed || roleCode <= 0) {
      if (roleCode <= 0) {
        ErrorHandler.handleError(Exception('Role code is missing.'));
      }
      return;
    }

    isLoading.value = true;
    try {
      // Prefer of/role/code (full list + isChecked). Fall back to
      // permission list + role/permissions selected ids.
      List<PermissionMaster> items = const [];
      final selected = <int>{};

      try {
        final ofRole = await roleRepository.getPermissionsOfRole(roleCode);
        if (ofRole.items.isNotEmpty) {
          items = ofRole.items;
          for (final item in ofRole.items) {
            if (item.isChecked && item.permissionCode > 0) {
              selected.add(item.permissionCode);
            }
          }
          // If API returned only assigned items (all checked / no flags),
          // treat them as selected and merge with full permission list.
          if (selected.isEmpty) {
            for (final item in ofRole.items) {
              if (item.permissionCode > 0) selected.add(item.permissionCode);
            }
            final all = await permissionRepository.listPermissions();
            if (all.items.isNotEmpty) {
              items = all.items;
            }
          }
        }
      } catch (_) {
        // Fall through to list + assigned ids.
      }

      if (items.isEmpty) {
        final all = await permissionRepository.listPermissions();
        items = all.items;
        try {
          final assigned = await roleRepository.getRolePermissions(roleCode);
          for (final item in assigned.items) {
            if (item.permissionCode > 0) selected.add(item.permissionCode);
          }
        } catch (_) {}
      }

      if (isClosed) return;
      permissions.assignAll(items);
      selectedPermissionCodes
        ..clear()
        ..addAll(selected.toList()..sort());
      selectionVersion.value++;

      if (kDebugMode) {
        debugPrint(
          'Role permission mapping role=$roleCode '
          'items=${items.length} selected=$selectedPermissionCodes',
        );
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  bool isSelected(int permissionCode) =>
      permissionCode > 0 && selectedPermissionCodes.contains(permissionCode);

  void togglePermission(PermissionMaster item) {
    if (isClosed || item.permissionCode <= 0) return;
    final next = selectedPermissionCodes.toSet();
    if (next.contains(item.permissionCode)) {
      next.remove(item.permissionCode);
    } else {
      next.add(item.permissionCode);
    }
    selectedPermissionCodes.assignAll(next.toList()..sort());
    selectionVersion.value++;
  }

  void selectAllVisible() {
    if (isClosed) return;
    final next = selectedPermissionCodes.toSet();
    for (final item in visiblePermissions) {
      if (item.permissionCode > 0) next.add(item.permissionCode);
    }
    selectedPermissionCodes.assignAll(next.toList()..sort());
    selectionVersion.value++;
  }

  /// True when every currently visible permission is selected.
  bool get isAllVisibleSelected {
    selectionVersion.value;
    searchQuery.value;
    selectedPermissionCodes.length;
    final visible = visiblePermissions
        .where((item) => item.permissionCode > 0)
        .toList();
    if (visible.isEmpty) return false;
    return visible.every((item) => isSelected(item.permissionCode));
  }

  void clearSelection() {
    if (isClosed) return;
    selectedPermissionCodes.clear();
    selectionVersion.value++;
  }

  Future<void> saveMapping() async {
    if (isClosed || isSaving.value || roleCode <= 0) return;

    final codes = selectedPermissionCodes.where((c) => c > 0).toList()..sort();
    if (codes.isEmpty) {
      ErrorHandler.handleError(
        Exception('Select at least one permission before saving.'),
      );
      return;
    }

    final request = RolePermissionMappingRequest(
      roleCode: roleCode,
      permissionCodes: codes,
    );

    if (kDebugMode) {
      debugPrint('role/permission/create body: ${request.toJson()}');
    }

    isSaving.value = true;
    try {
      await roleRepository.saveRolePermissions(request);
      if (isClosed) return;

      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      }

      Future<void>.delayed(const Duration(milliseconds: 150), () {
        ErrorHandler.showSuccess(
          'Role permissions saved successfully.',
          title: 'Permissions Assigned',
        );
      });
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
