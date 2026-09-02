import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/gallery_image_model.dart';
import 'gallery_fallback_art.dart';

class GalleryTile extends StatelessWidget {
  const GalleryTile({required this.image, super.key, this.onTap});

  final GalleryImageModel image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? url = image.gridUrl;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: url == null
            ? const GalleryFallbackArt()
            : Hero(
                tag: 'gallery-photo-${image.id}',
                child: AppNetworkImage(
                  url: url,

                  cacheKey: image.gridCacheKey,
                  errorWidget: const GalleryFallbackArt(),
                  placeholder: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(strokeWidth: 2.w),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
