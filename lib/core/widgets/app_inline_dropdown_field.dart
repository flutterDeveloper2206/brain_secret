import 'package:flutter/material.dart';

import 'app_searchable_dropdown_field.dart';
import 'glass_container.dart';

/// Inline expandable dropdown — no dialog / bottom sheet.
/// Tap header to expand an [AnimatedContainer] list of options.
class AppInlineDropdownField<T> extends StatefulWidget {
  const AppInlineDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.displayLabel,
    this.prefixIcon,
    this.enabled = true,
    this.isLoading = false,
    this.emptyMessage = 'No options',
    this.maxListHeight = 220,
  });

  final String label;
  final String hint;
  final T? value;
  final String? displayLabel;
  final List<AppSearchableDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final bool isLoading;
  final String emptyMessage;
  final double maxListHeight;

  @override
  State<AppInlineDropdownField<T>> createState() =>
      _AppInlineDropdownFieldState<T>();
}

class _AppInlineDropdownFieldState<T> extends State<AppInlineDropdownField<T>> {
  bool _expanded = false;

  String get _displayText {
    if (widget.displayLabel != null && widget.displayLabel!.trim().isNotEmpty) {
      return widget.displayLabel!;
    }
    if (widget.value == null) return '';
    for (final item in widget.items) {
      if (item.value == widget.value) return item.label;
    }
    return '';
  }

  void _toggle() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _expanded = !_expanded);
  }

  void _select(T value) {
    widget.onChanged(value);
    setState(() => _expanded = false);
  }

  @override
  void didUpdateWidget(covariant AppInlineDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _expanded) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _displayText;
    final hasValue = selected.isNotEmpty;
    final muted = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55);

    return GlassContainer(
      elevated: true,
      borderRadius: 14,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.enabled && !widget.isLoading ? _toggle : null,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(
                        widget.prefixIcon,
                        size: 22,
                        color: widget.enabled
                            ? theme.colorScheme.primary
                            : muted,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasValue ? selected : widget.hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  hasValue ? FontWeight.w600 : FontWeight.w400,
                              color: hasValue
                                  ? theme.textTheme.bodyMedium?.color
                                  : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.enabled
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55)
                              : muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity, height: 0)
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.maxListHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.35),
                        ),
                        Flexible(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _expanded ? 1 : 0,
                            child: widget.items.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        widget.emptyMessage,
                                        textAlign: TextAlign.center,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 4, 8, 8),
                                    itemCount: widget.items.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.2),
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = widget.items[index];
                                      final isSelected =
                                          item.value == widget.value;
                                      return Material(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                                .withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () => _select(item.value),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.label,
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 18,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
