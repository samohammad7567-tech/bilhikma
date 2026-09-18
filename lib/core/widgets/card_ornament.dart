import 'package:flutter/material.dart';
import 'app_icon.dart';

class CardOrnament extends StatelessWidget {
  const CardOrnament({required this.asset, required this.alignment, super.key});

  final String asset;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Directionality.of(context) == TextDirection.ltr;

    return Positioned.fill(
      child: Transform(
        alignment: Alignment.center,
        transform: isLtr
            ? Matrix4.diagonal3Values(-1, 1, 1)
            : Matrix4.identity(),
        child: AppIcon(
          asset: asset,
          fit: BoxFit.contain,
          alignment: alignment,
          padding: EdgeInsets.zero,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
