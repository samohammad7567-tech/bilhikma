import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../localization/lang_keys.dart';
import '../utils/my_screen_size.dart';
import 'custom_button.dart';
import 'custom_outline_button.dart';

class LiveSessionActionButton extends StatelessWidget {
  const LiveSessionActionButton({
    required this.isLive,
    required this.onWatch,
    required this.onRemind,
    super.key,
  });

  final bool isLive;
  final VoidCallback onWatch;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double width = MyScreenSize.value<double>(
      context,
      compact: 132,
      medium: 144,
      expanded: 156,
    );

    if (isLive) {
      return CustomButton(
        onPressed: onWatch,
        text: LangKeys.watchNow.tr(),
        width: width,
        height: 40,
        threeRadius: 8,
        lastRadius: 8,
        elevation: 0,
      );
    }

    return CustomOutlineButton(
      onPressed: onRemind,
      text: LangKeys.remindMeLater.tr(),
      width: width,
      height: 40,
      threeRadius: 8,
      lastRadius: 8,
      borderColor: colors.outlineVariant,
      backgroundColor: colors.surfaceContainerLowest,
      textColor: colors.onSurface,
    );
  }
}
