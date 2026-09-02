import 'package:flutter/animation.dart';

class SplashTimeline {
  const SplashTimeline._();

  static const Duration total = Duration(milliseconds: 3400);
  static const Interval logoPop = Interval(0, 0.32, curve: Curves.easeOutBack);
  static const Interval logoSettle = Interval(
    0.26,
    0.48,
    curve: Curves.easeOutCubic,
  );
  static const Interval ornaments = Interval(
    0.30,
    0.50,
    curve: Curves.easeOutCubic,
  );
  static const Interval title = Interval(0.50, 0.66, curve: Curves.easeOut);
  static const Interval tagline = Interval(0.58, 0.72, curve: Curves.easeOut);
  static const Interval background = Interval(
    0.72,
    1,
    curve: Curves.easeOutCubic,
  );
}

class SplashStageAnimations {
  SplashStageAnimations(AnimationController controller)
    : logoPop = controller.drive(CurveTween(curve: SplashTimeline.logoPop)),
      logoSettle = controller.drive(
        CurveTween(curve: SplashTimeline.logoSettle),
      ),
      ornamentsEntry = controller.drive(
        CurveTween(curve: SplashTimeline.ornaments),
      ),
      titleEntry = controller.drive(CurveTween(curve: SplashTimeline.title)),
      taglineEntry = controller.drive(
        CurveTween(curve: SplashTimeline.tagline),
      ),
      backgroundEntry = controller.drive(
        CurveTween(curve: SplashTimeline.background),
      );

  final Animation<double> logoPop;
  final Animation<double> logoSettle;
  final Animation<double> ornamentsEntry;
  final Animation<double> titleEntry;
  final Animation<double> taglineEntry;
  final Animation<double> backgroundEntry;
}
