import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../widgets/test_result_headline.dart';
import '../widgets/test_result_review.dart';
import '../widgets/test_result_score_card.dart';
import '../widgets/test_retry_note.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonTestResultBody extends StatelessWidget {
  const LessonTestResultBody({
    required this.result,
    this.showReview = false,
    super.key,
  });

  final QuizAttemptModel result;
  final bool showReview;

  @override
  Widget build(BuildContext context) {
    final bool pending = result.isPendingReview;

    return Column(
      children: <Widget>[
        SizedBox(height: (50).h(context)),
        AppCircleAvatar(size: (70).r(context)),
        SizedBox(height: (24).h(context)),
        TestResultHeadline(result: result),
        SizedBox(height: (10).h(context)),
        Text(
          LangKeys.resultLabel.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTheme.styles(context).labelStrong,
        ),
        SizedBox(height: (10).h(context)),
        TestResultScoreCard(result: result),

        if (pending) ...[
          SizedBox(height: (14).h(context)),
          TestRetryNote(
            messageKey: LangKeys.quizPendingReview,
            nextAttemptAt: null,
          ),
        ],

        if (!pending && result.isPassed != true) ...[
          SizedBox(height: (14).h(context)),
          TestRetryNote(
            nextAttemptAt: result.nextAttemptAt,
            attemptsLeft: result.attemptsLeft,
          ),
        ],

        if (showReview && result.questionResults.isNotEmpty) ...[
          SizedBox(height: (24).h(context)),
          TestResultReview(result: result),
        ],

        SizedBox(height: (24).h(context)),
      ],
    );
  }
}
