import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'settings_segment_tile.dart';

class SettingsSegmentedControl<T> extends StatelessWidget {
  const SettingsSegmentedControl({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    super.key,
    this.iconOf,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final IconData? Function(T option)? iconOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final IconData? Function(T option)? iconOf = this.iconOf;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: <Widget>[
          for (final T option in options)
            Expanded(
              child: SettingsSegmentTile(
                label: labelOf(option),
                icon: iconOf?.call(option),
                isSelected: option == selected,
                onTap: () => onSelected(option),
              ),
            ),
        ],
      ),
    );
  }
}
