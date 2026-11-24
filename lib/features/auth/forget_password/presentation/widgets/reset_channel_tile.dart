import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/themes/app_theme.dart';
import 'reset_channel_radio.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ResetChannelTile extends StatelessWidget {
  const ResetChannelTile({
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular((12).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: (14).w(context), vertical: (14).h(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((12).r(context)),
            border: Border.all(
              color: isSelected ? colors.tertiary : Colors.transparent,
              width: 1.4.w(context),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  labelKey.tr(),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isSelected
                      ? AppTheme.styles(context).optionLabelSelected
                      : AppTheme.styles(context).optionLabel,
                ),
              ),

              SizedBox(width: (12).w(context)),

              ResetChannelRadio(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
