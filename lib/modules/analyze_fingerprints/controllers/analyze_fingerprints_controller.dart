import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/customer_fingerprint.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../views/widgets/fingerprint_edit_sheet.dart';

class AnalyzeFingerprintsController extends GetxController {
  AnalyzeFingerprintsController({required this.repository});

  final FingerprintRepository repository;

  final RxList<CustomerFingerprint> fingerprints = <CustomerFingerprint>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  int get totalScans => fingerprints.length;
  int get fingerCount => groupedByFingerName.length;
  int get analyzedCount => fingerprints
      .where(
        (f) =>
            f.fingerType != null &&
            f.fingerType!.trim().isNotEmpty &&
            f.fingerValue > 0,
      )
      .length;

  /// Fingerprints grouped by [CustomerFingerprint.fingerName] (L1, L2, …).
  Map<String, List<CustomerFingerprint>> get groupedByFingerName {
    final map = <String, List<CustomerFingerprint>>{};
    for (final item in fingerprints) {
      final key = item.fingerName.trim().isEmpty ? 'Unknown' : item.fingerName;
      map.putIfAbsent(key, () => <CustomerFingerprint>[]).add(item);
    }

    final keys = map.keys.toList()
      ..sort((a, b) => _fingerSortKey(a).compareTo(_fingerSortKey(b)));

    return {for (final key in keys) key: map[key]!};
  }

  static int _fingerSortKey(String name) {
    final match =
        RegExp(r'^([LR])(\d+)$', caseSensitive: false).firstMatch(name);
    if (match == null) return 1000;
    final hand = match.group(1)!.toUpperCase() == 'L' ? 0 : 1;
    final digit = int.tryParse(match.group(2)!) ?? 9;
    return hand * 10 + digit;
  }

  static String fingerTitle(String fingerName) {
    final match =
        RegExp(r'^([LR])(\d+)$', caseSensitive: false).firstMatch(fingerName);
    if (match == null) return fingerName;
    final hand = match.group(1)!.toUpperCase() == 'L' ? 'Left' : 'Right';
    const names = {
      '1': 'Thumb',
      '2': 'Index',
      '3': 'Middle',
      '4': 'Ring',
      '5': 'Little',
    };
    final digit = match.group(2)!;
    final tip = names[digit] ?? 'Finger $digit';
    return '$hand $tip';
  }

  static String passLabel(String imageName) {
    final upper = imageName.toUpperCase();
    if (upper.endsWith('R')) return 'R';
    if (upper.endsWith('L')) return 'L';
    if (upper.endsWith('C')) return 'C';
    return imageName;
  }

  @override
  void onInit() {
    super.onInit();
    loadFingerprints();
  }

  Future<void> loadFingerprints() async {
    isLoading.value = true;
    try {
      final list = await repository.getCustomerFingerprints(
        customerId: AppConstants.defaultFingerprintCustomerId,
      );
      fingerprints.assignAll(list);
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> refreshList() => loadFingerprints();

  Future<void> openEdit(CustomerFingerprint item) async {
    await Get.bottomSheet(
      FingerprintEditSheet(
        item: item,
        isUpdating: isUpdating,
        onSave: (type, value) => _updateFingerprint(
          fingerprintId: item.fingerprintId,
          fingerType: type,
          fingerValue: value,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  Future<bool> _updateFingerprint({
    required int fingerprintId,
    required String fingerType,
    required int fingerValue,
  }) async {
    if (isUpdating.value) return false;
    isUpdating.value = true;
    try {
      await repository.updateCustomerFingerprint(
        fingerprintId: fingerprintId,
        fingerType: fingerType,
        fingerValue: fingerValue,
      );

      final index = fingerprints.indexWhere(
        (f) => f.fingerprintId == fingerprintId,
      );
      if (index >= 0) {
        fingerprints[index] = fingerprints[index].copyWith(
          fingerType: fingerType,
          fingerValue: fingerValue,
        );
      }

      GlassSnackbar.success('Analysis saved', title: 'Updated');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e);
      return false;
    } finally {
      if (!isClosed) isUpdating.value = false;
    }
  }
}
