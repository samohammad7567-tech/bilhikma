import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import 'test_option_indicator.dart';

class TestOptionTile extends StatelessWidget {
  const TestOptionTile({
    required this.label,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;

  final bool isMultiSelect;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background = isSelected
        ? colors.secondary
        : colors.tertiaryContainer;
    final Color foreground = isSelected ? colors.onSecondary : colors.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: AppTheme.styles(context).optionLabel.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              TestOptionIndicator(
                isSelected: isSelected,
                isMultiSelect: isMultiSelect,
                color: foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
