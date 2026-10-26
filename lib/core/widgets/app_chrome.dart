import 'package:flutter/material.dart';

import '../../features/security/presentation/widgets/security_guard.dart';

class AppChrome extends StatelessWidget {
  const AppChrome({required this.fontScale, required this.child, super.key});

  final double fontScale;
  final Widget? child;

  /// How far the OS accessibility setting may move text around the in-app
  /// [fontScale]. Pinning both ends to [fontScale] — as this did — overrode the
  /// user's system preference outright.
  static const double _minFactor = 0.9;
  static const double _maxFactor = 1.3;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    minScaleFactor: fontScale * _minFactor,
    maxScaleFactor: fontScale * _maxFactor,
    child: SecurityGuard(
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}
