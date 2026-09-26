import 'package:flutter/material.dart';

class AppSearchableDropdownItem<T> {
  const AppSearchableDropdownItem({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

/// Form-styled field that opens a searchable bottom sheet to pick a value.
class AppSearchableDropdownField<T> extends StatelessWidget {
  const AppSearchableDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.displayLabel,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.isLoading = false,
    this.loadItems,
    this.searchHint = 'Search…',
    this.emptyMessage = 'No results found',
  });

  final String label;
  final T? value;

  /// Current options (used for display label fallback).
  final List<AppSearchableDropdownItem<T>> items;

  /// Called when opening; return list shown in the sheet (fresh API data).
  final Future<List<AppSearchableDropdownItem<T>>> Function()? loadItems;

  final ValueChanged<T?> onChanged;
  final String? displayLabel;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isLoading;
  final String searchHint;
  final String emptyMessage;

  String? get _selectedLabel {
    if (displayLabel != null && displayLabel!.trim().isNotEmpty) {
      return displayLabel;
    }
    if (value == null) return null;
    for (final item in items) {
      if (item.value == value) return item.label;
    }
    return null;
  }

  Future<void> _openSheet(FormFieldState<T> field) async {
    if (!enabled) return;

    final navigatorContext = field.context;

    var sheetItems = items;
    if (loadItems != null) {
      sheetItems = await loadItems!();
    }

    if (!navigatorContext.mounted) return;

    final selected = await showModalBottomSheet<T>(
      context: navigatorContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchableSheet<T>(
          title: label,
          items: sheetItems,
          selected: value,
          searchHint: searchHint,
          emptyMessage: emptyMessage,
        );
      },
    );

    if (selected != null) {
      field.didChange(selected);
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<T>(
      key: ValueKey('searchable_${label}_$value'),
      initialValue: value,
      validator: validator,
      builder: (field) {
        final display = _selectedLabel;
        return InkWell(
          onTap: enabled && !isLoading ? () => _openSheet(field) : null,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            isEmpty: display == null || display.isEmpty,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.42),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorText: field.errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.18 : 0.55,
                  ),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              display?.isNotEmpty == true ? display! : (hint ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: display == null || display.isEmpty
                    ? theme.hintColor
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchableSheet<T> extends StatefulWidget {
  const _SearchableSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.searchHint,
    required this.emptyMessage,
  });

  final String title;
  final List<AppSearchableDropdownItem<T>> items;
  final T? selected;
  final String searchHint;
  final String emptyMessage;

  @override
  State<_SearchableSheet<T>> createState() => _SearchableSheetState<T>();
}

class _SearchableSheetState<T> extends State<_SearchableSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppSearchableDropdownItem<T>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where((item) => item.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final filtered = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.emptyMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final selected = item.value == widget.selected;
                          return ListTile(
                            title: Text(item.label),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            selected: selected,
                            onTap: () => Navigator.pop(context, item.value),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
