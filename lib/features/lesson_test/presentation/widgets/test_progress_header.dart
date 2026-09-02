import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import 'test_timer_chip.dart';
import '../../../../core/themes/app_theme.dart';

class TestProgressHeader extends StatelessWidget {
  const TestProgressHeader({
    required this.remaining,
    required this.questionNumber,
    required this.questionCount,
    required this.progress,
    super.key,
    this.questionRemaining,
    this.questionElapsed = Duration.zero,
  });

  final Duration remaining;

  final int questionNumber;
  final int questionCount;
  final double progress;

  final Duration? questionRemaining;
  final Duration questionElapsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'total_time'.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTheme.styles(context).labelSmall,
        ),

        SizedBox(height: 4.h),

        Align(
          alignment: Alignment.center,
          child: TestTimerChip(
            label: 'minute_value'.tr(
              namedArgs: <String, String>{
                'time': LessonDetailFormats.clock(remaining),
              },
            ),
          ),
        ),

        SizedBox(height: 10.h),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'question_number'.tr(
                  namedArgs: <String, String>{'index': '$questionNumber'},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).labelSmall,
              ),
            ),

            Text(
              '$questionNumber/$questionCount',
              maxLines: 1,
              style: AppTheme.styles(context).labelStrong,
            ),
          ],
        ),

        SizedBox(height: 6.h),

        AppProgressBar(progress: progress, showPercent: false),

        SizedBox(height: 8.h),

        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TestTimerChip(
            icon: Icons.access_time,
            label: LessonDetailFormats.clock(
              questionRemaining ?? questionElapsed,
            ),
          ),
        ),
      ],
    );
  }
}
