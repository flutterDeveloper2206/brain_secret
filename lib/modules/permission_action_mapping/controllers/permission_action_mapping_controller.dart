import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/permission_action_mapping_request.dart';
import '../../../data/models/permission_action_tree_node.dart';
import '../../../data/repositories/permission_master_repo.dart';

enum ActionCheckState { unchecked, checked, indeterminate }

class PermissionActionMappingController extends GetxController {
  PermissionActionMappingController({required this.repository});

  final PermissionMasterRepository repository;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<PermissionActionTreeNode> tree =
      <PermissionActionTreeNode>[].obs;

  /// Selected leaf API keys (`key` from server). Used for checkbox UI.
  final RxList<int> selectedActionCodes = <int>[].obs;

  /// Expanded nodes by API action key.
  final RxList<int> expandedActionCodes = <int>[].obs;

  final RxString searchQuery = ''.obs;
  final RxInt selectionVersion = 0.obs;

  final searchController = TextEditingController();

  late final int permissionCode;
  late final String permissionName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      permissionCode = _asInt(args['permissionCode']);
      permissionName = args['permissionName']?.toString() ?? '';
    } else if (args is int) {
      permissionCode = args;
      permissionName = '';
    } else {
      permissionCode = 0;
      permissionName = '';
    }
    loadTree();
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

  Future<void> loadTree() async {
    if (isClosed || permissionCode <= 0) {
      if (permissionCode <= 0) {
        ErrorHandler.handleError(Exception('Permission code is missing.'));
      }
      return;
    }
    isLoading.value = true;
    try {
      // Always load full tree + isChecked via:
      // GET rightsmaster/get/action/tree/for/{permissionId}
      final response =
          await repository.getActionTreeForPermission(permissionCode);
      if (isClosed) return;

      tree.assignAll(response.nodes);

      // Autofill checkboxes strictly from API `isChecked`.
      final selected = <int>{};
      _applyCheckedFromResponse(response.nodes, selected);
      selectedActionCodes
        ..clear()
        ..addAll(selected.toList()..sort());

      final expanded = <int>{};
      _defaultExpanded(response.nodes, expanded);
      _expandAncestorsOfSelected(response.nodes, selected, expanded);
      expandedActionCodes.assignAll(expanded.toList());
      selectionVersion.value++;

      if (kDebugMode) {
        debugPrint(
          'Action mapping load permission=$permissionCode '
          'api=get/action/tree/for '
          'nodes=${response.nodes.length} '
          'checkedKeys=${selectedActionCodes.toList()}',
        );
      }
    } catch (e) {
      if (!isClosed) ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  List<PermissionActionTreeNode> get visibleTree {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return tree.toList();
    return _filterTree(tree, query);
  }

  List<PermissionActionTreeNode> _filterTree(
    List<PermissionActionTreeNode> nodes,
    String query,
  ) {
    final result = <PermissionActionTreeNode>[];
    for (final node in nodes) {
      final childMatches = _filterTree(node.children, query);
      final selfMatch = node.title.toLowerCase().contains(query);
      if (selfMatch || childMatches.isNotEmpty) {
        result.add(
          PermissionActionTreeNode(
            actionCode: node.actionCode,
            title: node.title,
            isChecked: node.isChecked,
            isLeaf: node.isLeaf,
            children: childMatches.isNotEmpty
                ? childMatches
                : (selfMatch ? node.children : const []),
          ),
        );
      }
    }
    return result;
  }

  void _defaultExpanded(
    List<PermissionActionTreeNode> nodes,
    Set<int> keys,
  ) {
    for (final node in nodes) {
      if (node.hasChildren && node.actionCode > 0) {
        keys.add(node.actionCode);
        for (final child in node.children) {
          if (child.hasChildren && child.actionCode > 0) {
            keys.add(child.actionCode);
          }
        }
      }
    }
  }

  /// Autofill from GET tree:
  /// - `isChecked: true` on leaf → select that key
  /// - `isChecked: true` on parent → select all descendant leaf keys
  /// - `isChecked: false` → leave unselected (unless a child is checked)
  void _applyCheckedFromResponse(
    List<PermissionActionTreeNode> nodes,
    Set<int> selected,
  ) {
    for (final node in nodes) {
      if (node.hasChildren) {
        if (node.isChecked) {
          _collectSaveableLeafCodes(node.children, selected);
        }
        // Always walk children so nested checked leaves are applied
        // even when parent isChecked is false (partial selection).
        _applyCheckedFromResponse(node.children, selected);
      } else if (node.isChecked && node.actionCode > 0) {
        selected.add(node.actionCode);
      }
    }
  }

  void _expandAncestorsOfSelected(
    List<PermissionActionTreeNode> nodes,
    Set<int> selected,
    Set<int> expanded,
  ) {
    bool walk(PermissionActionTreeNode node) {
      if (!node.hasChildren) {
        return selected.contains(node.actionCode);
      }
      var any = false;
      for (final child in node.children) {
        if (walk(child)) any = true;
      }
      if (any && node.actionCode > 0) {
        expanded.add(node.actionCode);
      }
      return any;
    }

    for (final node in nodes) {
      walk(node);
    }
  }

  void _collectSaveableLeafCodes(
    List<PermissionActionTreeNode> nodes,
    Set<int> out,
  ) {
    for (final node in nodes) {
      if (node.hasChildren) {
        _collectSaveableLeafCodes(node.children, out);
      } else if (node.actionCode > 0) {
        out.add(node.actionCode);
      }
    }
  }

  void toggleExpanded(PermissionActionTreeNode node) {
    if (isClosed || !node.hasChildren || node.actionCode <= 0) return;
    final next = expandedActionCodes.toSet();
    if (next.contains(node.actionCode)) {
      next.remove(node.actionCode);
    } else {
      next.add(node.actionCode);
    }
    expandedActionCodes.assignAll(next.toList());
    selectionVersion.value++;
  }

  bool isExpanded(PermissionActionTreeNode node) {
    if (searchQuery.value.trim().isNotEmpty && node.hasChildren) {
      return true;
    }
    return node.actionCode > 0 &&
        expandedActionCodes.contains(node.actionCode);
  }

  bool _isSelected(int actionCode) =>
      actionCode > 0 && selectedActionCodes.contains(actionCode);

  ActionCheckState checkState(PermissionActionTreeNode node) {
    selectionVersion.value;

    if (!node.hasChildren) {
      return _isSelected(node.actionCode)
          ? ActionCheckState.checked
          : ActionCheckState.unchecked;
    }

    final leafCodes = <int>{};
    _collectSaveableLeafCodes(node.children, leafCodes);
    if (leafCodes.isEmpty) {
      return ActionCheckState.unchecked;
    }

    final selectedCount = leafCodes.where(_isSelected).length;
    if (selectedCount == 0) return ActionCheckState.unchecked;
    if (selectedCount == leafCodes.length) return ActionCheckState.checked;
    return ActionCheckState.indeterminate;
  }

  void toggleNode(PermissionActionTreeNode node) {
    if (isClosed) return;

    final codes = <int>{};
    if (node.hasChildren) {
      _collectSaveableLeafCodes(node.children, codes);
    } else if (node.actionCode > 0) {
      codes.add(node.actionCode);
    }

    if (codes.isEmpty) return;

    final next = selectedActionCodes.toSet();
    final state = checkState(node);
    if (state == ActionCheckState.checked) {
      next.removeAll(codes);
    } else {
      next.addAll(codes);
    }
    selectedActionCodes.assignAll(next.toList()..sort());
    selectionVersion.value++;
  }

  /// Build `action_codes` for create API (same shape as web curl).
  /// Includes leaf keys + fully-checked parent keys (e.g. 23).
  List<int> buildActionCodesForCreateApi() {
    final codes = <int>{
      ...selectedActionCodes.where((c) => c > 0),
    };

    void addFullyCheckedParents(List<PermissionActionTreeNode> nodes) {
      for (final node in nodes) {
        if (!node.hasChildren) continue;
        final leafCodes = <int>{};
        _collectSaveableLeafCodes(node.children, leafCodes);
        if (leafCodes.isNotEmpty &&
            leafCodes.every(_isSelected) &&
            node.actionCode > 0) {
          codes.add(node.actionCode);
        }
        addFullyCheckedParents(node.children);
      }
    }

    addFullyCheckedParents(tree);
    return codes.toList()..sort();
  }

  Future<void> saveMapping() async {
    if (isClosed || isSaving.value || permissionCode <= 0) return;

    final codes = buildActionCodesForCreateApi();
    if (codes.isEmpty) {
      ErrorHandler.handleError(
        Exception('Select at least one action before saving.'),
      );
      return;
    }

    // Matches:
    // POST rightsmaster/permission/action/create
    // { "permission_code": "1", "action_codes": [1, 2, 23] }
    final request = PermissionActionMappingRequest(
      permissionCode: '$permissionCode',
      actionCodes: codes,
    );

    if (kDebugMode) {
      debugPrint('permission/action/create body: ${request.toJson()}');
    }

    isSaving.value = true;
    try {
      await repository.savePermissionActions(request);
      if (isClosed) return;

      // Auto-back first so snackbar shows on the permission list.
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      }

      Future<void>.delayed(const Duration(milliseconds: 150), () {
        ErrorHandler.showSuccess(
          'Permission actions saved successfully.',
          title: 'Actions Saved',
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
