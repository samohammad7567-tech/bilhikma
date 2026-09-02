import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/models/lesson_progress_model.dart';
import '../../data/models/lesson_detail_model.dart';
import '../../../../core/utils/lesson_detail_formats.dart';

class LessonSummaryPosition extends StatelessWidget {
  const LessonSummaryPosition({
    required this.detail,
    required this.progress,
    super.key,
  });

  final LessonDetailModel detail;
  final LessonProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double ratio = progress.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: <Widget>[
              Text(
                LessonDetailFormats.position(
                  totalSeconds: detail.durationSeconds,
                  elapsedSeconds: progress.maxPositionSeconds,
                ),
                maxLines: 1,
                style: AppTheme.styles(context).progressLabel,
              ),

              const Spacer(),

              Text(
                '${progress.progressPercent}%',
                maxLines: 1,
                style: AppTheme.styles(context).progressLabel,
              ),
            ],
          ),
        ),

        SizedBox(height: 6.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6.h,
            backgroundColor: colors.surfaceContainerLowest,
            valueColor: AlwaysStoppedAnimation<Color>(
              colors.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
