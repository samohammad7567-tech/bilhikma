import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../refactor/quiz_review_answer.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestReviewAnswerTile extends StatelessWidget {
  const TestReviewAnswerTile({required this.answer, super.key});

  final QuizReviewAnswer answer;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<String> images = answer.imageUrls;
    final String feedback = answer.normalizedFeedback;

    return Padding(
      padding: EdgeInsets.only(bottom: (4).h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (images.isNotEmpty) ...<Widget>[
            _images(context, images, colors),
            SizedBox(width: (8).w(context)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (answer.text.trim().isNotEmpty)
                  TestHtmlText(answer.text.trim(), style: styles.labelSmall),
                if (feedback.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: (3).h(context)),
                    child: TestHtmlText(
                      '${LangKeys.quizOptionFeedback.tr()}: $feedback',
                      style: styles.labelSmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colors.secondary,
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

  Widget _images(
      BuildContext context, List<String> images, ColorScheme colors) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (int index = 0; index < images.length; index++) ...<Widget>[
          if (index > 0)
            Icon(
              Icons.compare_arrows,
              size: (16).r(context),
              color: colors.onSurfaceVariant,
            ),
          TestMediaImage(
            url: images[index],
            width: (52).w(context),
            height: (52).h(context),
            radius: 10,
            elevated: false,
            padding: EdgeInsets.all((3).r(context)),
          ),
        ],
      ],
    );
  }
}
