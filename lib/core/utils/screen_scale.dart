import 'package:flutter/material.dart';

import 'my_screen_size.dart';

/// Convenience extensions that replicate the flutter_screenutil API
/// but are backed by [MyScreenSize] – no global state, no init widget needed.
///
/// Usage inside a build method:
/// ```dart
/// SizedBox(height: (16).h(context))
/// BorderRadius.circular((12).r(context))
/// fontSize: (14).sp(context)
/// width: (104).w(context)
/// ```
// Two separate extensions are needed because Dart tokenises integer literals
// like `16.w` as the double literal `16.` followed by identifier `w`, which
// causes "method not found on int/double" errors when using a single `on num`
// extension.  Defining the same methods on both int and double resolves every
// literal form without requiring callers to write `(16).w(context)`.

extension ScreenScaleDouble on double {
  double w(BuildContext context) => MyScreenSize.w(context, this);
  double h(BuildContext context) => MyScreenSize.h(context, this);
  double r(BuildContext context) => MyScreenSize.r(context, this);
  double sp(BuildContext context) => MyScreenSize.sp(context, this);
}

extension ScreenScaleInt on int {
  double w(BuildContext context) => MyScreenSize.w(context, toDouble());
  double h(BuildContext context) => MyScreenSize.h(context, toDouble());
  double r(BuildContext context) => MyScreenSize.r(context, toDouble());
  double sp(BuildContext context) => MyScreenSize.sp(context, toDouble());
}
