import 'package:flutter/material.dart';

class ScreenSize {
  ScreenSize._();

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isTablet(BuildContext context) =>
      size(context).shortestSide >= 600;

  static bool isMobile(BuildContext context) => !isTablet(context);
}
