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
  bool? _pendingMobile;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pendingMobile = MyScreenSize.isMobile(context);
    _scheduleApply();
  }

  void _scheduleApply() {
    final int generation = ++_generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      _applyOrientation();
    });
  }

  void _applyOrientation() {
    final bool? isMobile = _pendingMobile;
    if (isMobile == null || _lastMobile == isMobile) return;

    _lastMobile = isMobile;
    setPreferredOrientationByDeviceType(isMobile: isMobile);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
