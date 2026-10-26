import 'package:flutter/material.dart';

import '../themes/app_motion.dart';

/// Cross-fades between a screen's loading, error, empty and content states.
///
/// Children are matched the way [AnimatedSwitcher] matches them, so a swap
/// between two different widget types animates while an ordinary rebuild of
/// the same one does not. [StackFit.passthrough] hands both the incoming and
/// the outgoing child the parent's own constraints, so a scrollable keeps its
/// full height for the length of the fade.
///
/// Reduced motion renders the child directly, with no switcher in the tree.
class AppStateSwitcher extends StatelessWidget {
  const AppStateSwitcher({required this.child, super.key, this.duration});

  final Widget child;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return AnimatedSwitcher(
      duration: duration ?? AppMotion.normal,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) =>
          Stack(
            fit: StackFit.passthrough,
            children: <Widget>[...previousChildren, ?currentChild],
          ),
      child: child,
    );
  }
}
