import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonArtwork extends StatelessWidget {
  const LessonArtwork({
    required this.aspectRatio,
    super.key,
    this.imageUrl,
    this.framePadding,
  });
  final double aspectRatio;
  final String? imageUrl;

  final double? framePadding;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = this.imageUrl;
    final double inset = framePadding ?? 8;

    return Container(
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((6).r(context)),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: imageUrl == null || imageUrl.isEmpty
              ? _bundled()
              : AppNetworkImage(url: imageUrl, errorWidget: _bundled()),
        ),
      ),
    );
  }

  Widget _bundled() =>
      Image.asset(AppAssets.assetsLogoOrnament, fit: BoxFit.cover);
}
