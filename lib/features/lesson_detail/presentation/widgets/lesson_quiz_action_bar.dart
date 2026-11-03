import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/coming_soon_sheet.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/lesson_detail_model.dart';

class LessonQuizActionBar extends StatelessWidget {
  const LessonQuizActionBar({
    required this.detail,
    required this.isArticleRead,
    required this.canStartQuiz,
    super.key,
    this.onGoToTest,
  });

  final LessonDetailModel detail;
  final bool isArticleRead;
  final bool canStartQuiz;
  final Future<void> Function(LessonDetailModel detail)? onGoToTest;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool needsArticleRead = detail.isArticle && !isArticleRead;

    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: colors.shadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (detail.hasPassedQuiz) ...<Widget>[
                _PassedNote(color: colors.primary),
                SizedBox(height: 10.h),
              ],
              if (needsArticleRead) ...<Widget>[
                Text(
                  LangKeys.quizArticleNotRead.tr(),
                  style: AppTheme.styles(
                    context,
                  ).cardCaption.copyWith(color: colors.error),
                ),
                SizedBox(height: 10.h),
              ],
              CustomButton(
                onPressed: canStartQuiz
                    ? () => onGoToTest == null
                          ? ComingSoonSheet.show(
                              context,
                              messageKey: 'coming_soon_test',
                            )
                          : onGoToTest!(detail)
                    : () {},
                text: detail.hasPassedQuiz
                    ? LangKeys.viewResultAndReview.tr()
                    : LangKeys.goToTest.tr(),
                width: double.infinity,
                height: 46,
                threeRadius: 8.r,
                lastRadius: 8.r,
                backgroundColor: canStartQuiz
                    ? colors.secondary
                    : colors.surfaceContainerHighest,
                textColor: canStartQuiz ? colors.onSecondary : colors.outline,
                elevation: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassedNote extends StatelessWidget {
  const _PassedNote({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.check_circle, size: 18.r, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'test_passed_note'.tr(),
            style: AppTheme.styles(context).cardCaption,
          ),
        ),
      ],
    );
  }
}
