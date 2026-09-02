import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/lesson_model.dart';
import 'app_toast.dart';
import 'lesson_card_details.dart';
import 'lesson_media_tag.dart';
import 'lesson_save_icon.dart';
import 'lesson_thumbnail.dart';
import 'ornamented_card.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, super.key, this.onTap});

  final LessonModel lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = lesson.isLocked;

    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? () => _reportLocked(context) : onTap,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: OrnamentBackdrop()),

            Padding(
              padding: EdgeInsets.all(10.w),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    LessonThumbnail(
                      mediaType: lesson.type,
                      imageUrl: lesson.thumbnailUrl,
                      isLocked: isLocked,
                    ),

                    SizedBox(width: 12.w),

                    Expanded(child: LessonCardDetails(lesson: lesson)),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              bottom: 0,
              child: LessonMediaTag(mediaType: lesson.type),
            ),

            if (!isLocked)
              PositionedDirectional(
                start: 4.w,
                top: 4.h,
                child: LessonSaveIcon(
                  lessonId: lesson.id,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.85),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _reportLocked(BuildContext context) =>
      AppToast.show(context, 'lesson_locked'.tr());
}
