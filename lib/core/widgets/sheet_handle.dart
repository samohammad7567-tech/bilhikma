import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (42).w(context),
      height: (4).h(context),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular((4).r(context)),
      ),
    );
  }
}
