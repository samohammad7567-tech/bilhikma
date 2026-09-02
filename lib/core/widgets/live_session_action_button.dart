import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final double width = 132.w * MediaQuery.textScalerOf(context).scale(1);

    if (isLive) {
      return CustomButton(
        onPressed: onWatch,
        text: 'watch_now'.tr(),
        width: width,
        height: 40.h,
        threeRadius: 8.r,
        lastRadius: 8.r,
        elevation: 0,
      );
    }

    return CustomOutlineButton(
      onPressed: onRemind,
      text: 'remind_me_later'.tr(),
      width: width,
      height: 40.h,
      threeRadius: 8.r,
      lastRadius: 8.r,
      borderColor: colors.outlineVariant,
      backgroundColor: colors.surfaceContainerLowest,
      textColor: colors.onSurface,
    );
  }
}
