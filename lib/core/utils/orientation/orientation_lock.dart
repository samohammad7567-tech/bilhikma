import 'package:flutter/material.dart';

import '../my_screen_size.dart';
import 'orientation_util.dart';

class OrientationLock extends StatefulWidget {
  const OrientationLock({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  bool? _lastMobile;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MyScreenSize.isMobile(context);
    if (_lastMobile != isMobile) {
      _lastMobile = isMobile;
      setPreferredOrientationByDeviceType(isMobile: isMobile);
    }
    return widget.child;
  }
}
