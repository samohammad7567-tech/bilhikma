import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_box.dart';

/// One placeholder line of text.
///
/// Reserves the full line box the real [Text] would occupy — `fontSize` times
/// the font's line factor — and paints a shorter bar inside it. That is what
/// keeps a skeleton from shifting the layout when the sentence arrives: the
/// bar is the visible part, the box is the part that has to match.
class SkeletonTextLine extends StatelessWidget {
  const SkeletonTextLine({
    required this.fontSize,
    super.key,
    this.width,
    this.widthFactor = 1,
    this.surface,
  });

  /// The `.sp` size of the style this line stands in for.
  final double fontSize;

  /// Fixed bar width. Takes precedence over [widthFactor].
  final double? width;

  /// Bar width as a fraction of the available width.
  final double widthFactor;

  final Color? surface;

  /// Cairo renders at roughly this multiple of its font size.
  static const double _lineFactor = 1.5;

  @override
  Widget build(BuildContext context) {
    final double? width = this.width;

    final Widget bar = SkeletonBox(
      height: fontSize * 0.78,
      width: width,
      radius: 4.r,
      surface: surface,
    );

    return SizedBox(
      height: fontSize * _lineFactor,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: width != null
            ? bar
            : FractionallySizedBox(widthFactor: widthFactor, child: bar),
      ),
    );
  }
}
