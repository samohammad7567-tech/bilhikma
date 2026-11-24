import 'package:flutter/material.dart';

/// Material 3 window size classes: compact < 600, medium 600–839, expanded >= 840.
enum WindowSize { compact, medium, expanded }

class MyScreenSize {
  MyScreenSize._();

  // ── Design baseline (matches the original 412×917 Figma canvas) ─────────────
  static const double _designWidth = 412;
  static const double _designHeight = 917;

  // ── Raw screen values ────────────────────────────────────────────────────────
  // Each *Of getter subscribes only to the value it reads, so rebuilds are
  // minimal.
  static Size size(BuildContext context) => MediaQuery.sizeOf(context);
  static double width(BuildContext context) => size(context).width;
  static double height(BuildContext context) => size(context).height;
  static double shortestSide(BuildContext context) =>
      size(context).shortestSide;
  static double dpr(BuildContext context) =>
      MediaQuery.devicePixelRatioOf(context);
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  // ── Safe area & keyboard ─────────────────────────────────────────────────────
  static double topPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).top;
  static double bottomPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;
  static double keyboardHeight(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;
  static bool isKeyboardOpen(BuildContext context) =>
      keyboardHeight(context) > 0;

  // ── Accessibility text scaling ───────────────────────────────────────────────
  // Read it, don't fight it.
  static TextScaler textScaler(BuildContext context) =>
      MediaQuery.textScalerOf(context);

  // ── Device / layout class ────────────────────────────────────────────────────
  // Uses shortest side so a phone in landscape is still classified as a phone.
  static bool isTablet(BuildContext context) => shortestSide(context) >= 600;
  static bool isMobile(BuildContext context) => !isTablet(context);
  static bool isCompactHeight(BuildContext context) => height(context) < 600;

  static WindowSize windowSize(BuildContext context) {
    final double w = width(context);
    if (w < 600) return WindowSize.compact;
    if (w < 840) return WindowSize.medium;
    return WindowSize.expanded;
  }

  /// Pick a value per layout class:
  /// ```dart
  /// MyScreenSize.value(context, compact: 1, medium: 2, expanded: 3)
  /// ```
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
  }) => switch (windowSize(context)) {
    WindowSize.compact => compact,
    WindowSize.medium => medium ?? compact,
    WindowSize.expanded => expanded ?? medium ?? compact,
  };

  // ── Design-relative scaling ───────────────────────────────────────────────────
  // These replicate what flutter_screenutil's .w / .h / .r / .sp did when the
  // design size was 412 × 917.  Call them when you have a dp value that was
  // measured on that canvas and want it to scale with the actual device.
  //
  // Rules of thumb (same as before):
  //   sp()  – font sizes and icon sizes that must stay legible
  //   w()   – horizontal lengths, horizontal padding, icon widths
  //   h()   – vertical lengths, vertical padding
  //   r()   – border radii (uses width ratio so circles stay circular)

  static const double _minScale = 0.75;
  static const double _maxWidthScale = 1.1;
  static const double _maxHeightScale = 1.0;

  static const double _minTextScale = 0.9;
  static const double _maxTextScale = 1.0;
  static double widthScale(BuildContext context) =>
      (width(context) / _designWidth).clamp(_minScale, _maxWidthScale);

  static double heightScale(BuildContext context) =>
      (height(context) / _designHeight).clamp(_minScale, _maxHeightScale);

  /// Scales [value] relative to the design width (412 px), with a capped ratio.
  static double w(BuildContext context, double value) =>
      value * widthScale(context);

  /// Scales [value] relative to the design height (917 px), with a capped ratio.
  static double h(BuildContext context, double value) =>
      value * heightScale(context);

  /// Scales [value] for border radii – uses the capped width ratio only.
  static double r(BuildContext context, double value) =>
      value * widthScale(context);

  /// Scales [value] for font / icon sizes.
  /// Uses the smaller of the two capped ratios so text never grows out of
  /// control on wide screens.
  static double sp(BuildContext context, double value) {
    final double widthRatio = widthScale(context);
    final double heightRatio = heightScale(context);
    final double scale = widthRatio < heightRatio ? widthRatio : heightRatio;
    return value * scale.clamp(_minTextScale, _maxTextScale);
  }

  // ── Fraction helpers ─────────────────────────────────────────────────────────
  // For hero images, max content widths, bottom-sheet heights, etc.
  // Never use for padding, icons, or text – use w/h/sp for those.

  static double widthFraction(
    BuildContext context,
    double fraction, {
    double min = 0,
    double max = double.infinity,
  }) => (width(context) * fraction).clamp(min, max).toDouble();

  static double heightFraction(
    BuildContext context,
    double fraction, {
    double min = 0,
    double max = double.infinity,
  }) => (height(context) * fraction).clamp(min, max).toDouble();

  static double contentMaxWidth(BuildContext context) => value<double>(
    context,
    compact: double.infinity,
    medium: 900,
    expanded: 1040,
  );

  static int galleryColumns(BuildContext context) =>
      value<int>(context, compact: 2, medium: 3, expanded: 4);

  static double bottomChromeHeight(BuildContext context) =>
      isTablet(context) ? 0 : 70;

  static double navRailWidth(BuildContext context) =>
      isTablet(context) ? 96 : 0;
}
