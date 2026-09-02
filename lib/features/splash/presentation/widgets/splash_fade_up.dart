import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashFadeUp extends StatelessWidget {
  const SplashFadeUp({required this.entry, required this.child, super.key});

  final Animation<double> entry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double travel = 14.h;

    return AnimatedBuilder(
      animation: entry,
      builder: (BuildContext context, Widget? child) {
        final double t = entry.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, travel * (1 - t)),
          child: Opacity(opacity: t, child: child),
        );
      },
      child: child,
    );
  }
}
