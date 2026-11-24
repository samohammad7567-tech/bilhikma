import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
      borderRadius: BorderRadius.circular((10).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isSelected ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (8).w(context), vertical: (10).h(context)),
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
                SizedBox(width: (6).w(context)),
                Icon(icon, size: (16).r(context), color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
