import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    required this.errorWidget,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.memCacheWidth,
    this.cacheKey,
  });

  final String url;

  final Widget errorWidget;

  final BoxFit fit;
  final double? width;
  final double? height;

  final Widget? placeholder;

  final int? memCacheWidth;

  final String? cacheKey;

  @override
  Widget build(BuildContext context) {
    final Widget? placeholder = this.placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: cacheKey,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,

      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: placeholder == null
          ? null
          : (BuildContext context, String url) => placeholder,
      errorWidget: (BuildContext context, String url, Object error) =>
          errorWidget,
    );
  }
}
