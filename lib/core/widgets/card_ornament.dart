import 'package:flutter/material.dart';
import 'app_icon.dart';

/// One decorative motif filling a card, mirrored as a whole when the app reads
/// left to right.
///
/// [alignment] is given in Arabic terms — a plain [Alignment], never an
/// [AlignmentDirectional]. Direction is applied once here, by flipping the
/// entire layer, which moves the motif to the opposite corner *and* mirrors the
/// artwork in a single step. Letting the alignment resolve itself as well would
/// flip the position twice and land it back where it started.
class CardOrnament extends StatelessWidget {
  const CardOrnament({required this.asset, required this.alignment, super.key});

  final String asset;

  /// Where the motif sits in Arabic. English gets the mirror of it.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Directionality.of(context) == TextDirection.ltr;

    return Positioned.fill(
      child: Transform(
        alignment: Alignment.center,
        transform: isLtr
            ? Matrix4.diagonal3Values(-1, 1, 1)
            : Matrix4.identity(),
        child: AppIcon(
          asset: asset,
          fit: BoxFit.contain,
          alignment: alignment,
          padding: EdgeInsets.zero,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
