import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/lesson_model.dart';
import 'app_toast.dart';
import 'lesson_card_details.dart';
import 'lesson_media_tag.dart';
import 'lesson_save_icon.dart';
import 'lesson_thumbnail.dart';
import 'ornamented_card.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, super.key, this.onTap});

  final LessonModel lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = lesson.isLocked;

    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular((14).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? () => _reportLocked(context) : onTap,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: OrnamentBackdrop()),

            Padding(
              padding: EdgeInsets.all((10).r(context)),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    LessonThumbnail(
                      mediaType: lesson.type,
                      imageUrl: lesson.thumbnailUrl,
                      isLocked: isLocked,
                    ),

                    SizedBox(width: (12).w(context)),

                    Expanded(child: LessonCardDetails(lesson: lesson)),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: (0).w(context),
              bottom: (0).h(context),
              child: LessonMediaTag(mediaType: lesson.type),
            ),

            if (!isLocked)
              PositionedDirectional(
                start: (4).w(context),
                top: (4).h(context),
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
