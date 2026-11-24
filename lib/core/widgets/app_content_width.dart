import 'package:flutter/material.dart';

import '../utils/my_screen_size.dart';

class AppContentWidth extends StatelessWidget {
  const AppContentWidth({required this.child, this.maxWidth, super.key});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double resolvedMaxWidth =
        maxWidth ?? MyScreenSize.contentMaxWidth(context);
    if (!resolvedMaxWidth.isFinite) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
        child: child,
      ),
    );
  }
}
