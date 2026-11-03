import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import 'test_timer_chip.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/localization/lang_keys.dart';
import '../cubit/lesson_test_cubit.dart';

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
        ],

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

        SizedBox(height: 4.h),

        SizedBox(height: 16.h, child: _saveStatus(context)),
      ],
    );
  }

  Widget _saveStatus(BuildContext context) {
    final (String? key, Color? color) = switch (saveStatus) {
      LessonTestSaveStatus.saving => (
        LangKeys.quizSaving,
        Theme.of(context).colorScheme.outline,
      ),
      LessonTestSaveStatus.saved => (
        LangKeys.quizSaved,
        Theme.of(context).colorScheme.primary,
      ),
      LessonTestSaveStatus.failed => (
        LangKeys.quizSaveFailed,
        Theme.of(context).colorScheme.error,
      ),
      LessonTestSaveStatus.idle => (null, null),
    };

    if (key == null || color == null) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        key.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.styles(context).labelSmall.copyWith(color: color),
      ),
    );
  }
}
