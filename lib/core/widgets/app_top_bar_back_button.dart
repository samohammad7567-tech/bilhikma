import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
          width: (44).w(context),
          height: (44).h(context),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: (18).r(context),
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
