import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/content_type_enum.dart';
import 'app_network_image.dart';
import 'lesson_fallback_art.dart';
import 'lesson_lock_scrim.dart';

class LessonThumbnail extends StatelessWidget {
  const LessonThumbnail({
    required this.mediaType,
    super.key,
    this.isLocked = false,
    this.imageUrl,
    this.width,
  });

  final ContentType mediaType;

  final bool isLocked;
  final String? imageUrl;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = this.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: width ?? 104.w,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (imageUrl == null)
              const LessonFallbackArt()
            else
              AppNetworkImage(
                url: imageUrl,
                errorWidget: const LessonFallbackArt(),
              ),

            if (isLocked) LessonLockScrim(mediaType: mediaType),
          ],
        ),
      ),
    );
  }
}
