import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../refactor/quiz_review_answer.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';

class TestReviewAnswerTile extends StatelessWidget {
  const TestReviewAnswerTile({required this.answer, super.key});

  final QuizReviewAnswer answer;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);
    final String? imageUrl = answer.imageUrl?.trim();
    final String feedback = answer.normalizedFeedback;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (imageUrl != null && imageUrl.isNotEmpty) ...<Widget>[
            TestMediaImage(
              url: imageUrl,
              width: 52.w,
              height: 52.h,
              radius: 10,
              elevated: false,
              padding: EdgeInsets.all(3.w),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (answer.text.trim().isNotEmpty)
                  TestHtmlText(answer.text.trim(), style: styles.labelSmall),
                if (feedback.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: TestHtmlText(
                      '${LangKeys.quizOptionFeedback.tr()}: $feedback',
                      style: styles.labelSmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
