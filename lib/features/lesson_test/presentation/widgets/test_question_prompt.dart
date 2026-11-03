import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import 'test_timer_chip.dart';

class TestQuestionPrompt extends StatelessWidget {
  const TestQuestionPrompt({required this.prompt, super.key, this.remaining});

  final String prompt;

  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final Duration? timeLeft = remaining;

    if (prompt.trim().isEmpty) {
      if (timeLeft == null) return const SizedBox.shrink();

      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TestTimerChip(
          icon: Icons.access_time,
          label: LessonDetailFormats.clock(timeLeft),
        ),
      );
    }

    final Widget text = Text(
      prompt,
      textAlign: TextAlign.start,
      style: AppTheme.styles(context).labelStrong,
    );

    if (timeLeft == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: text),

        SizedBox(width: 10.w),

        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: TestTimerChip(
            icon: Icons.access_time,
            label: LessonDetailFormats.clock(timeLeft),
          ),
        ),
      ],
    );
  }
}
