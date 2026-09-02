import 'orientation_util.dart';
import 'package:flutter/material.dart';

class OrientationLock extends StatefulWidget {
  const OrientationLock({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (!_done) {
      _done = true;
      setPreferredOrientationByDevice(context);
    }
    return widget.child;
  }
}
