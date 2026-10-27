import 'package:flutter/material.dart';

class AppContentWidth extends StatelessWidget {
  const AppContentWidth({required this.child, this.maxWidth = 900, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!maxWidth.isFinite) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
