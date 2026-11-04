import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_network_image.dart';

class TestMediaImage extends StatelessWidget {
  const TestMediaImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.radius = 16,
    this.padding = const EdgeInsets.all(6),
    this.elevated = true,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius borderRadius = BorderRadius.circular(radius.r);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: colors.outlineVariant, width: 1),
        boxShadow: elevated
            ? <BoxShadow>[
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.10),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: AppNetworkImage(
            url: url,
            fit: fit,
            errorWidget: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 28.r,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
