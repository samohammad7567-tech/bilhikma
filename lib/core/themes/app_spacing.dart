/// Names the spacing scale already in de-facto use across the app, so adopting
/// a token is a pure rename and never a visual shift.
///
/// `.w` / `.h` is still applied at the call site, as everywhere else.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

/// Corner radii observed in the existing widgets. `.r` is applied at the call
/// site.
class AppRadii {
  AppRadii._();

  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 14;
  static const double pill = 20;
}
