import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.asset,
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.alignment = Alignment.center,
    this.padding = EdgeInsetsGeometry.zero,
  });
  final String asset;
  final double? size;

  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color? color = this.color;
    final double? width = this.width ?? size;
    final double? height = this.height ?? size;

    final Widget artwork = asset.endsWith('.svg')
        ? SvgPicture.asset(
            asset,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
            alignment: alignment,
            colorFilter: color == null
                ? null
                : ColorFilter.mode(color, BlendMode.srcIn),
          )
        : Image.asset(
            asset,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            color: color,
            colorBlendMode: color == null ? null : BlendMode.srcIn,
          );

    if (padding == EdgeInsets.zero) return artwork;

    return Padding(padding: padding, child: artwork);
  }
}
