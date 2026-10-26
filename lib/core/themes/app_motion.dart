import 'package:flutter/animation.dart';

/// Motion tokens. The values match the idiom already in use by `app_toast.dart`
/// (220ms / `easeOutCubic`) and `splash_timeline.dart`, so adopting them is
/// never a change in feel.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  /// Delay between consecutive items in a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 40);

  /// One full skeleton sweep.
  static const Duration shimmer = Duration(milliseconds: 1100);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeIn;
}
