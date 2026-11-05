import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/lesson_detail/data/models/quiz_summary_model.dart';
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
    final QuizSummaryModel? quiz = lesson.quiz;

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

        if (quiz != null) ...<Widget>[
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _QuizBadge(quiz: quiz),
          ),
        ],

        if (lesson.status.showsProgress) ...<Widget>[
          SizedBox(height: 10.h),
          AppProgressBar(progress: lesson.progress.progress),
        ],
      ],
    );
  }
}

class _QuizBadge extends StatelessWidget {
  const _QuizBadge({required this.quiz});

  final QuizSummaryModel quiz;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    final bool passed = quiz.hasPassed;
    final bool isBlocking = quiz.isBlocking;

    final String label = passed
        ? 'quiz_passed'.tr()
        : (isBlocking ? 'quiz_mandatory'.tr() : 'quiz_optional'.tr());

    final Color background = passed
        ? colors.tertiary.withValues(alpha: 0.12)
        : (isBlocking
              ? colors.error.withValues(alpha: 0.10)
              : colors.primary.withValues(alpha: 0.10));

    final Color foreground = passed
        ? colors.tertiary
        : (isBlocking ? colors.error : colors.primary);

    final IconData icon = passed ? Icons.check_circle_outline : Icons.quiz_outlined;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12.sp, color: foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.badgeLabel.copyWith(
              color: foreground,
              fontSize: 9.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
