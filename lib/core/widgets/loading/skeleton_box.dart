import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single placeholder block. Paints an opaque, theme-derived tone so the
/// [AppShimmer] highlight above it has something to sweep across.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height,
    this.width,
    this.radius,
    this.isCircular = false,
    this.surface,
  });

  final double? height;
  final double? width;
  final double? radius;

  final bool isCircular;

  /// The colour this block sits on, when that is not the scaffold surface.
  final Color? surface;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height ?? 12.h,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.onSurface.withValues(alpha: 0.10),
          surface ?? colors.surface,
        ),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(radius ?? 8.r),
      ),
    );
  }
}
