import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class SettingsSegmentTile extends StatelessWidget {
  const SettingsSegmentTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final IconData? icon = this.icon;
    final AppTextStyles styles = AppTheme.styles(context);

    final Color foreground = isSelected
        ? colors.onTertiaryContainer
        : colors.onSurfaceVariant;

    return Material(
      color: isSelected ? colors.tertiaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isSelected ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (isSelected
                              ? styles.optionLabelSelected
                              : styles.optionLabel)
                          .copyWith(color: foreground),
                ),
              ),

              if (icon != null) ...<Widget>[
                SizedBox(width: 6.w),
                Icon(icon, size: 16.w, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
