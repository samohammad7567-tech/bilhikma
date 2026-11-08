import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import 'test_timer_chip.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/localization/lang_keys.dart';
import '../cubit/lesson_test_cubit.dart';
import 'test_save_status.dart';

class TestProgressHeader extends StatelessWidget {
  const TestProgressHeader({
    required this.remaining,
    required this.questionNumber,
    required this.questionCount,
    required this.progress,
    required this.saveStatus,
    super.key,
    this.showTotalTimer = true,
  });

  final Duration remaining;

  final int questionNumber;
  final int questionCount;
  final double progress;
  final LessonTestSaveStatus saveStatus;

  final bool showTotalTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showTotalTimer) ...<Widget>[
          Text(
            LangKeys.totalTime.tr(),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppTheme.styles(context).labelSmall,
          ),

          SizedBox(height: 4.h),

          Align(
            alignment: Alignment.center,
            child: TestTimerChip(
              label: LangKeys.minuteValue.tr(
                namedArgs: <String, String>{
                  'time': LessonDetailFormats.clock(remaining),
                },
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                LangKeys.questionNumber.tr(
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

        SizedBox(height: 4.h),

        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 16.h),
          child: TestSaveStatus(saveStatus: saveStatus),
        ),
      ],
    );
  }
}
