import 'package:flutter/material.dart';

import 'app_motion.dart';

/// The app's route transition: a fade-through with a very small scale lift.
///
/// Deliberately direction-neutral — nothing slides — so the same motion reads
/// correctly in Arabic RTL and English LTR without mirroring. Under reduced
/// motion the incoming page is shown with no animation at all.
class AppFadeThroughTransitions extends PageTransitionsBuilder {
  const AppFadeThroughTransitions();

  @override
  Duration get transitionDuration => AppMotion.normal;

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final Animation<double> enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit.flipped,
    );

    return FadeTransition(
      opacity: enter,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1).animate(enter),
        child: child,
      ),
    );
  }
}

/// Applied to both themes, so every route shares one transition.
const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: AppFadeThroughTransitions(),
    TargetPlatform.iOS: AppFadeThroughTransitions(),
    TargetPlatform.fuchsia: AppFadeThroughTransitions(),
    TargetPlatform.linux: AppFadeThroughTransitions(),
    TargetPlatform.macOS: AppFadeThroughTransitions(),
    TargetPlatform.windows: AppFadeThroughTransitions(),
  },
);
