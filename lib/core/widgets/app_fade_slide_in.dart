import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_motion.dart';

/// The one entrance motion the app reuses: a fade with a small upward slide.
///
/// Pass [index] to stagger a run of items. The delay is folded into an
/// [Interval] on a single tween rather than a timer, so there is nothing to
/// cancel when the item is disposed mid-flight.
///
/// Under reduced motion the child is rendered immediately, mirroring the
/// early-out in the skeleton primitives.
class AppFadeSlideIn extends StatelessWidget {
  const AppFadeSlideIn({
    required this.child,
    super.key,
    this.index = 0,
    this.maxStaggerIndex = 8,
    this.duration,
    this.rise,
  });

  final Widget child;

  /// Position in the run. Beyond [maxStaggerIndex] the delay stops growing, so
  /// a long list does not animate for ever.
  final int index;
  final int maxStaggerIndex;

  final Duration? duration;

  /// Distance travelled upward, in logical pixels. Defaults to `12.h`.
  final double? rise;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final int steps = index.clamp(0, maxStaggerIndex);
    final Duration delay = AppMotion.stagger * steps;
    final Duration total = (duration ?? AppMotion.normal) + delay;

    final double start = total.inMicroseconds == 0
        ? 0
        : delay.inMicroseconds / total.inMicroseconds;

    final double distance = rise ?? 12.h;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.enter),
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * distance),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
