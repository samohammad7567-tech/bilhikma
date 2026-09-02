import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import '../../data/models/test_result_model.dart';
import '../widgets/test_result_headline.dart';
import '../widgets/test_result_score_card.dart';
import '../widgets/test_retry_note.dart';
import '../../../../core/themes/app_theme.dart';

class LessonTestResultBody extends StatelessWidget {
  const LessonTestResultBody({
    required this.result,
    required this.onNextLesson,
    required this.onBackToLessons,
    super.key,
  });

  final TestResultModel result;

  final VoidCallback onNextLesson;
  final VoidCallback onBackToLessons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 60.h),

        AppCircleAvatar(size: 70.w),

        SizedBox(height: 28.h),

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

        SizedBox(height: 18.h),

        ..._actions(context),
      ],
    );
  }

  List<Widget> _actions(BuildContext context) {
    if (!result.passed) {
      return <Widget>[
        _primary(context, 'back_to_lessons'.tr(), onBackToLessons),

        SizedBox(height: 10.h),

        TestRetryNote(days: result.retryAfterDays),
      ];
    }

    return <Widget>[
      _primary(context, 'next_lesson'.tr(), onNextLesson),

      SizedBox(height: 10.h),

      CustomOutlineButton(
        onPressed: onBackToLessons,
        text: 'back_to_lessons'.tr(),
        width: double.infinity,
        height: 46.h,
        threeRadius: 8.r,
        lastRadius: 8.r,
        borderColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.secondary,
      ),
    ];
  }

  Widget _primary(BuildContext context, String label, VoidCallback onPressed) =>
      CustomButton(
        onPressed: onPressed,
        text: label,
        width: double.infinity,
        height: 46.h,
        threeRadius: 8.r,
        lastRadius: 8.r,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
      );
}
