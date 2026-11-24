import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonAttachmentAction extends StatelessWidget {
  const LessonAttachmentAction({
    required this.labelKey,
    required this.icon,
    required this.isFilled,
    required this.onPressed,
    super.key,
    this.isBusy = false,
    this.isExpanded = false,
  });

  final String labelKey;
  final IconData icon;
  final bool isFilled;
  final VoidCallback? onPressed;

  final bool isBusy;

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;
    final Color ink = isFilled ? Colors.white : colors.onSurfaceVariant;

    return Material(
      color: isFilled
          ? colors.secondaryContainer.withValues(alpha: isEnabled ? 1 : 0.4)
          : colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular((8).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isBusy ? null : onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (6).h(context)),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  labelKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.styles(context).badgeLabel.copyWith(
                    color: ink.withValues(alpha: isEnabled ? 1 : 0.5),
                  ),
                ),
              ),

              SizedBox(width: (4).w(context)),

              if (isBusy)
                SizedBox(
                  width: (14).w(context),
                  height: (14).h(context),
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6.r(context),
                    color: ink,
                  ),
                )
              else
                Icon(
                  icon,
                  size: (14).r(context),
                  color: ink.withValues(alpha: isEnabled ? 1 : 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
