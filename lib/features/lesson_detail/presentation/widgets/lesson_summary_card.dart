import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/ornamented_card.dart';
import '../../../../core/models/lesson_progress_model.dart';
import '../../../../core/widgets/lesson_status_badge.dart';
import '../../../lessons/presentation/refactor/lesson_formats.dart';
import '../../../../core/widgets/lesson_meta_item.dart';
import '../../data/models/lesson_detail_model.dart';
import 'lesson_summary_position.dart';

class LessonSummaryCard extends StatelessWidget {
  const LessonSummaryCard({
    required this.detail,
    super.key,
    this.progress = const LessonProgressModel(),
  });

  final LessonDetailModel detail;

  final LessonProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);
    final String? subjectName = detail.subjectName;
    final DateTime? publishedAt = detail.publishedAt;

    return OrnamentedCard(
      radius: 12.r,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  detail.title,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cardTitle,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 8.w),
                child: LessonStatusBadge(status: detail.status),
              ),
            ],
          ),

          if ((subjectName ?? '').isNotEmpty) ...<Widget>[
            SizedBox(height: 4.h),
            Text(
              subjectName!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.cardSubtitle,
            ),
          ],

          if (publishedAt != null) ...<Widget>[
            SizedBox(height: 6.h),
            LessonMetaItem(
              icon: Icons.calendar_month_outlined,
              label: LessonFormats.date(publishedAt),
            ),
          ],

          if (detail.durationSeconds > 0) ...<Widget>[
            SizedBox(height: 10.h),
            LessonSummaryPosition(detail: detail, progress: progress),
          ],
        ],
      ),
    );
  }
}
