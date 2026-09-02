import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/lesson_test_model.dart';
import '../widgets/test_intro_card.dart';
import '../../../../core/themes/app_theme.dart';

class LessonTestIntroBody extends StatelessWidget {
  const LessonTestIntroBody({
    required this.test,
    required this.onStart,
    super.key,
  });

  final LessonTestModel test;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 60.h),

        AppCircleAvatar(size: 70.w),

        SizedBox(height: 24.h),

        Text(
          test.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).sectionTitle,
        ),

        SizedBox(height: 18.h),

        TestIntroCard(
          rows: <TestIntroRow>[
            TestIntroRow(
              icon: Icons.format_list_numbered,
              label: 'questions_count'.tr(),
              value: 'questions_value'.tr(
                namedArgs: <String, String>{'count': '${test.questionCount}'},
              ),
            ),
            TestIntroRow(
              icon: Icons.timer_outlined,
              label: 'test_duration'.tr(),
              value: 'minute_count'.tr(
                namedArgs: <String, String>{
                  'count': '${test.duration.inMinutes}',
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 18.h),

        Text(
          'pass_threshold_note'.tr(
            namedArgs: <String, String>{'percent': '${test.passPercent}'},
          ),
          textAlign: TextAlign.center,
          style: AppTheme.styles(context).bodyStrong.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 40.h),

        CustomButton(
          onPressed: onStart,
          text: 'start_test'.tr(),
          width: double.infinity,
          height: 48.h,
          threeRadius: 8.r,
          lastRadius: 8.r,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          textColor: Theme.of(context).colorScheme.onSecondary,
          elevation: 0,
        ),
      ],
    );
  }
}
