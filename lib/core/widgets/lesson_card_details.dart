import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/lessons/presentation/refactor/lesson_formats.dart';
import '../models/lesson_model.dart';
import '../themes/app_theme.dart';
import 'app_progress_bar.dart';
import 'lesson_meta_item.dart';
import 'lesson_status_badge.dart';

class LessonCardDetails extends StatelessWidget {
  const LessonCardDetails({required this.lesson, super.key});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);
    final DateTime? publishedAt = lesson.publishedAt;

    final bool hasDuration = lesson.durationSeconds > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                lesson.title,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styles.cardTitle,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 8.w),
              child: LessonStatusBadge(status: lesson.status),
            ),
          ],
        ),

        if ((lesson.description ?? '').isNotEmpty) ...<Widget>[
          SizedBox(height: 4.h),
          Text(
            lesson.description!,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.cardSubtitle,
          ),
        ],

        SizedBox(height: 10.h),

        Row(
          children: <Widget>[
            if (publishedAt != null)
              Flexible(
                child: LessonMetaItem(
                  icon: Icons.calendar_month_outlined,
                  label: LessonFormats.date(publishedAt),
                ),
              ),

            if (publishedAt != null && hasDuration) SizedBox(width: 14.w),

            if (hasDuration)
              Flexible(
                child: LessonMetaItem(
                  icon: Icons.access_time,
                  label: LessonFormats.duration(lesson.duration),
                ),
              ),
          ],
        ),

        if (lesson.status.showsProgress) ...<Widget>[
          SizedBox(height: 10.h),
          AppProgressBar(progress: lesson.progress.progress),
        ],
      ],
    );
  }
}
