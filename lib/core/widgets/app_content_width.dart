import 'package:flutter/material.dart';

/// Caps how wide a screen's content may grow and centres it.
///
/// Phones are narrower than the cap, so nothing changes there. On a tablet or
/// a split-screen window it stops cards from stretching into bands of text
/// with a thumbnail marooned at one end.
class AppContentWidth extends StatelessWidget {
  const AppContentWidth({required this.child, super.key, this.maxWidth});

  final Widget child;

  /// Logical pixels — deliberately not `.w`, since this is a real-estate
  /// decision about the device, not a design-size measurement to scale.
  final double? maxWidth;

  static const double defaultMaxWidth = 680;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? defaultMaxWidth),
      child: child,
    ),
  );
}
