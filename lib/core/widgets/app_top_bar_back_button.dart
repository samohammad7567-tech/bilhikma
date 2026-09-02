import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTopBarBackButton extends StatelessWidget {
  const AppTopBarBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44.w,
          height: 44.w,

          // Icons.arrow_back_ios_new carries matchTextDirection: true, so
          // Flutter already mirrors it for Arabic. Swapping it for
          // arrow_forward_ios here would flip an icon that is auto-mirroring
          // too, and the two flips would cancel out into a left-pointing back
          // arrow in RTL.
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18.w,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
