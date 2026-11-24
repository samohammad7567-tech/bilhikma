import 'package:flutter/material.dart';

import '../../../../core/enums/sleep_timer_option_enum.dart';
import '../refactor/settings_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SleepTimerOptionRow extends StatelessWidget {
  const SleepTimerOptionRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final SleepTimerOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (8).w(context), vertical: (14).h(context)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                SettingsFormats.sleepTimer(option),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isSelected
                    ? AppTheme.styles(context).optionLabelSelected
                    : AppTheme.styles(context).optionLabel,
              ),
            ),

            if (isSelected)
              Icon(Icons.check, size: (18).r(context), color: colors.secondaryContainer),
          ],
        ),
      ),
    );
  }
}
