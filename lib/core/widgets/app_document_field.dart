import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Document picker row matching shared field styling.
class AppDocumentField extends StatelessWidget {
  const AppDocumentField({
    super.key,
    required this.label,
    required this.fileName,
    required this.onPick,
    this.isRequired = true,
  });

  final String label;
  final RxnString fileName;
  final VoidCallback onPick;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final selected = fileName.value;
      final hasFile = selected != null && selected.isNotEmpty;

      return FormField<String>(
        validator: (_) {
          if (!isRequired) return null;
          if (!hasFile) return '$label is required';
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  onPick();
                  state.didChange(fileName.value);
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  // Keep label pinned to the border so it never overlaps value text.
                  isEmpty: false,
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: const Icon(Icons.upload_file_outlined),
                    suffixIcon: Icon(
                      hasFile ? Icons.check_circle_outline : Icons.attach_file,
                      color: hasFile ? theme.colorScheme.primary : null,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.42),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.18 : 0.55,
                        ),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    errorText: state.errorText,
                  ),
                  child: Text(
                    hasFile ? selected! : 'Tap to upload',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasFile
                          ? theme.textTheme.bodyLarge?.color
                          : theme.textTheme.bodyMedium?.color?.withValues(
                              alpha: 0.45,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
