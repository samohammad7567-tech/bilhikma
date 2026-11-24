import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SettingsTileTrailing extends StatelessWidget {
  const SettingsTileTrailing({required this.isBusy, super.key});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isBusy) {
      return SizedBox(
        width: (16).w(context),
        height: (16).h(context),
        child: CircularProgressIndicator(
          strokeWidth: (2).r(context),
          color: colors.secondary,
        ),
      );
    }

    return Icon(
      Icons.arrow_forward_ios,
      size: (14).r(context),
      color: colors.onSurfaceVariant,
    );
  }
}
