import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/role_master.dart';
import '../../../data/models/role_master_request.dart';
import '../../../data/repositories/role_master_repo.dart';
import '../../role_permission_mapping/bindings/role_permission_mapping_binding.dart';
import '../../role_permission_mapping/views/role_permission_mapping_view.dart';

class RoleMasterController extends GetxController {
  RoleMasterController({required this.repository});

  final RoleMasterRepository repository;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isFormVisible = false.obs;
  final RxList<RoleMaster> roles = <RoleMaster>[].obs;
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
    loadRoles();
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

  List<RoleMaster> get filteredRoles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return roles.toList();
    return roles.where((item) {
      final haystack = [
        item.roleCode.toString(),
        item.roleName,
        item.roleDescription,
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

  Future<void> loadRoles({bool force = false}) async {
    if (isClosed || (isLoading.value && !force)) return;
    isLoading.value = true;
    try {
      final response = await repository.listRoles();
      if (isClosed) return;
      roles.assignAll(response.items);
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
      RoleMaster? match;
      for (final item in roles) {
        if (item.roleCode == code) {
          match = item;
          break;
        }
      }
      if (match != null) {
        editRole(match);
        return;
      }
    }
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    isBlock.value = false;
    formKey.currentState?.reset();
  }

  void editRole(RoleMaster item) {
    if (isClosed) return;
    editingCode.value = item.roleCode;
    highlightedCode.value = item.roleCode;
    nameController.text = item.roleName;
    descriptionController.text = item.roleDescription;
    isActive.value = item.isActive;
    isBlock.value = item.isBlock;
    isFormVisible.value = true;
  }

  Future<void> saveRole() async {
    if (isClosed || isSaving.value) return;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final request = RoleMasterRequest(
      roleCode: editingCode.value,
      roleName: name,
      roleDescription: description,
      isActive: isActive.value,
      isBlock: isBlock.value,
    );

    isSaving.value = true;
    try {
      if (isEditing) {
        await repository.updateRole(request);
        if (isClosed) return;
        ErrorHandler.showSuccess('Role updated successfully.');
        closeForm();
        await loadRoles(force: true);
      } else {
        final createResponse = await repository.createRole(request);
        if (isClosed) return;
        ErrorHandler.showSuccess('Role created successfully.');

        await loadRoles(force: true);
        if (isClosed) return;

        final newCode = _resolveCreatedRoleCode(createResponse.data, name);
        closeForm();
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

  int _resolveCreatedRoleCode(dynamic data, String createdName) {
    final fromData = _roleCodeFromData(data);
    if (fromData > 0) return fromData;

    final lower = createdName.trim().toLowerCase();
    RoleMaster? match;
    for (final item in roles) {
      if (item.roleName.trim().toLowerCase() == lower) {
        if (match == null || item.roleCode > match.roleCode) {
          match = item;
        }
      }
    }
    return match?.roleCode ?? 0;
  }

  int _roleCodeFromData(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) return int.tryParse(data.trim()) ?? 0;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [
        map['role_code'],
        map['roleCode'],
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

  Future<void> openPermissionMapping(RoleMaster item) async {
    highlightedCode.value = item.roleCode;
    await Get.to(
      () => const RolePermissionMappingView(),
      binding: RolePermissionMappingBinding(),
      transition: Transition.cupertino,
      arguments: {
        'roleCode': item.roleCode,
        'roleName': item.roleName,
      },
    );
  }
}
