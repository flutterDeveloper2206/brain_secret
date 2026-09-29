import 'package:get/get.dart';

import '../../../core/errors/error_handler.dart';
import '../../../data/models/customer_fingerprint.dart';
import '../../../data/models/entity_picker_result.dart';
import '../../../data/repositories/fingerprint_repo.dart';
import '../../../routes/app_routes.dart';

class AnalyzeFingerprintsController extends GetxController {
  AnalyzeFingerprintsController({required this.repository});

  final FingerprintRepository repository;

  final RxList<CustomerFingerprint> fingerprints = <CustomerFingerprint>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<EntityPickerResult> selectedEntity = Rxn<EntityPickerResult>();

  bool get hasSelection => selectedEntity.value != null;

  String get selectionLabel {
    final entity = selectedEntity.value;
    if (entity == null) return '';
    if (entity.familyName.trim().isNotEmpty) {
      return entity.familyName;
    }
    return entity.customerName;
  }

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

  Future<void> openEntityPicker() async {
    final result = await Get.toNamed(Routes.entityPicker);
    if (result is! EntityPickerResult) return;

    selectedEntity.value = result;
    fingerprints.clear();
    await loadFingerprints();
  }

  Future<void> loadFingerprints() async {
    final entity = selectedEntity.value;
    if (entity == null) return;

    isLoading.value = true;
    try {
      final list = await repository.getCustomerFingerprints(
        customerId: entity.familyId,
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
    final result = await Get.toNamed(
      Routes.analysis,
      arguments: {'fingerprint': item},
    );
    if (result == true) await loadFingerprints();
  }
}
