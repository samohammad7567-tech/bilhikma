import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/test_result_headline.dart';
import '../widgets/test_result_score_card.dart';
import '../widgets/test_retry_note.dart';

class LessonTestResultBody extends StatelessWidget {
  const LessonTestResultBody({
    required this.state,
    required this.result,
    required this.onNextLesson,
    required this.onBackToLessons,
    super.key,
  });

  final LessonTestState state;
  final QuizAttemptModel result;
  final void Function(int lessonId)? onNextLesson;
  final VoidCallback onBackToLessons;

  @override
  Widget build(BuildContext context) {
    final bool pending = result.isPendingReview;
    final bool canGoNext =
        state.canGoToNextLesson &&
        state.nextLessonId != null &&
        onNextLesson != null;

    return Column(
      children: <Widget>[
        SizedBox(height: 50.h),
        AppCircleAvatar(size: 70.w),
        SizedBox(height: 24.h),
        TestResultHeadline(result: result),
        SizedBox(height: 10.h),
        Text(
          'result_label'.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTheme.styles(context).labelStrong,
        ),
        SizedBox(height: 10.h),
        TestResultScoreCard(result: result),

        if (pending) ...[
          SizedBox(height: 14.h),
          TestRetryNote(
            messageKey: LangKeys.quizPendingReview,
            nextAttemptAt: null,
          ),
        ],

        if (state.nextLessonLocked && !pending) ...[
          SizedBox(height: 14.h),
          TestRetryNote(
            messageKey: LangKeys.nextLessonLocked,
            nextAttemptAt: null,
          ),
        ],

        if (!canGoNext && !pending) ...[
          SizedBox(height: 14.h),
          TestRetryNote(
            nextAttemptAt: result.nextAttemptAt,
            attemptsLeft: result.attemptsLeft,
          ),
        ],

        SizedBox(height: 24.h),
        ..._actions(context, canGoNext: canGoNext),
      ],
    );
  }

  List<Widget> _actions(BuildContext context, {required bool canGoNext}) {
    final Widget back = CustomOutlineButton(
      onPressed: onBackToLessons,
      text: 'back_to_lessons'.tr(),
      width: double.infinity,
      height: 46.h,
      threeRadius: 8.r,
      lastRadius: 8.r,
      borderColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.secondary,
    );

    if (!canGoNext) return <Widget>[back];

    return <Widget>[
      CustomButton(
        onPressed: () => onNextLesson!(state.nextLessonId!),
        text: 'next_lesson'.tr(),
        width: double.infinity,
        height: 46.h,
        threeRadius: 8.r,
        lastRadius: 8.r,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
      ),
      SizedBox(height: 10.h),
      back,
    ];
  }
}
