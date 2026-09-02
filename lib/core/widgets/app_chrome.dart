import 'package:flutter/material.dart';
import '../../features/security/presentation/widgets/security_guard.dart';

class AppChrome extends StatelessWidget {
  const AppChrome({required this.fontScale, required this.child, super.key});

  final double fontScale;
  final Widget? child;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    minScaleFactor: fontScale,
    maxScaleFactor: fontScale,
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
