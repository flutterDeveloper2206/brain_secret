import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/glass_snackbar.dart';
import '../../../../data/models/customer_fingerprint.dart';
import '../../controllers/analyze_fingerprints_controller.dart';

/// Owns its [TextEditingController]s so they are only disposed with the sheet.
class FingerprintEditSheet extends StatefulWidget {
  const FingerprintEditSheet({
    super.key,
    required this.item,
    required this.isUpdating,
    required this.onSave,
  });

  final CustomerFingerprint item;
  final RxBool isUpdating;
  final Future<bool> Function(String fingerType, int fingerValue) onSave;

  @override
  State<FingerprintEditSheet> createState() => _FingerprintEditSheetState();
}

class _FingerprintEditSheetState extends State<FingerprintEditSheet> {
  late final TextEditingController _typeController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.item.fingerType ?? '');
    _valueController = TextEditingController(
      text: widget.item.fingerValue == 0
          ? ''
          : widget.item.fingerValue.toString(),
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final type = _typeController.text.trim();
    final value = int.tryParse(_valueController.text.trim());
    if (type.isEmpty) {
      GlassSnackbar.warning(
        'Please enter a finger type',
        title: 'Missing type',
      );
      return;
    }
    if (value == null) {
      GlassSnackbar.warning(
        'Please enter a numeric value',
        title: 'Missing value',
      );
      return;
    }

    final ok = await widget.onSave(type, value);
    if (ok && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Obx(() {
          final updating = widget.isUpdating.value;
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.7,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Text(
                    'Update analysis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AnalyzeFingerprintsController.fingerTitle(widget.item.fingerName)} · ${widget.item.fingerImageName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _typeController,
                    enabled: !updating,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Finger type',
                      hintText: 'e.g. ws',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _valueController,
                    enabled: !updating,
                    decoration: InputDecoration(
                      labelText: 'Finger value',
                      hintText: 'e.g. 10',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: updating ? null : Get.back,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: updating ? null : _submit,
                          child: updating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
