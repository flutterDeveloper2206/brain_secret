import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/permission_master.dart';
import '../../../data/models/permission_master_request.dart';
import '../../../data/repositories/permission_master_repo.dart';
import '../../../routes/app_routes.dart';

class PermissionMasterController extends GetxController {
  PermissionMasterController({required this.repository});

  final PermissionMasterRepository repository;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isFormVisible = false.obs;
  final RxList<PermissionMaster> permissions = <PermissionMaster>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnInt highlightedCode = RxnInt();

  final RxnInt editingCode = RxnInt();
  final RxBool isActive = true.obs;
  final RxBool isBlock = false.obs;

  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadPermissions();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  bool get isEditing => editingCode.value != null;

  void setActive(bool value) {
    if (isClosed) return;
    isActive.value = value;
    if (value) isBlock.value = false;
  }

  void setBlocked(bool value) {
    if (isClosed) return;
    isBlock.value = value;
    if (value) isActive.value = false;
  }

  List<PermissionMaster> get filteredPermissions {
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

  void onSearchChanged(String value) {
    if (isClosed) return;
    searchQuery.value = value;
  }

  void clearSearch() {
    if (isClosed) return;
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> loadPermissions({bool force = false}) async {
    if (isClosed || (isLoading.value && !force)) return;
    isLoading.value = true;
    try {
      final response = await repository.listPermissions();
      if (isClosed) return;
      permissions.assignAll(response.items);
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void openCreateForm() {
    if (isClosed) return;
    editingCode.value = null;
    highlightedCode.value = null;
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    isBlock.value = false;
    formKey.currentState?.reset();
    isFormVisible.value = true;
  }

  void closeForm() {
    if (isClosed) return;
    isFormVisible.value = false;
    editingCode.value = null;
    highlightedCode.value = null;
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    isBlock.value = false;
    formKey.currentState?.reset();
  }

  void resetForm() {
    if (isClosed) return;
    if (isEditing) {
      final code = editingCode.value;
      PermissionMaster? match;
      for (final item in permissions) {
        if (item.permissionCode == code) {
          match = item;
          break;
        }
      }
      if (match != null) {
        editPermission(match);
        return;
      }
    }
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    isBlock.value = false;
    formKey.currentState?.reset();
  }

  void editPermission(PermissionMaster item) {
    if (isClosed) return;
    editingCode.value = item.permissionCode;
    highlightedCode.value = item.permissionCode;
    nameController.text = item.permissionName;
    descriptionController.text = item.permissionDescription;
    isActive.value = item.isActive;
    isBlock.value = item.isBlock;
    isFormVisible.value = true;
  }

  Future<void> savePermission() async {
    if (isClosed || isSaving.value) return;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final request = PermissionMasterRequest(
      permissionCode: editingCode.value,
      permissionName: name,
      permissionDescription: description,
      isActive: isActive.value,
      isBlock: isBlock.value,
    );

    isSaving.value = true;
    try {
      if (isEditing) {
        await repository.updatePermission(request);
        if (isClosed) return;
        ErrorHandler.showSuccess('Permission updated successfully.');
        closeForm();
        await loadPermissions(force: true);
      } else {
        final createResponse = await repository.createPermission(request);
        if (isClosed) return;
        ErrorHandler.showSuccess('Permission created successfully.');

        await loadPermissions(force: true);
        if (isClosed) return;

        final newCode = _resolveCreatedPermissionCode(
          createResponse.data,
          name,
        );
        closeForm();

        // Select the new permission so user can tap Map.
        if (newCode > 0) {
          highlightedCode.value = newCode;
        }
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  /// Prefer create-response id; fall back to list match by name.
  int _resolveCreatedPermissionCode(dynamic data, String createdName) {
    final fromData = _permissionCodeFromData(data);
    if (fromData > 0) return fromData;

    final lower = createdName.trim().toLowerCase();
    PermissionMaster? match;
    for (final item in permissions) {
      if (item.permissionName.trim().toLowerCase() == lower) {
        if (match == null || item.permissionCode > match.permissionCode) {
          match = item;
        }
      }
    }
    return match?.permissionCode ?? 0;
  }

  int _permissionCodeFromData(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) return int.tryParse(data.trim()) ?? 0;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [
        map['permission_code'],
        map['permissionCode'],
        map['id'],
        map['Id'],
        map['code'],
        map['value'],
      ];
      for (final candidate in candidates) {
        final parsed = _asInt(candidate);
        if (parsed > 0) return parsed;
      }
    }
    return 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> openActionMapping(PermissionMaster item) async {
    highlightedCode.value = item.permissionCode;
    await Get.toNamed(
      Routes.permissionActionMapping,
      arguments: {
        'permissionCode': item.permissionCode,
        'permissionName': item.permissionName,
      },
    );
  }
}
