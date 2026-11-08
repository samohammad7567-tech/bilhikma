import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';
import 'test_match_pairs_helpers.dart';
import 'test_pair_tile.dart';
import 'test_question_prompt.dart';

class TestMatchPairsQuestion extends StatelessWidget {
  const TestMatchPairsQuestion({
    required this.question,
    required this.answer,
    required this.matchOrder,
    required this.onPromptTap,
    required this.onMatchTap,
    super.key,
    this.selectedPromptId,
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final List<String> matchOrder;

  final ValueChanged<String> onPromptTap;
  final ValueChanged<String> onMatchTap;

  final String? selectedPromptId;
  final Duration? questionRemaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: question.prompt,
          remaining: questionRemaining,
          imageUrl: question.imageUrl,
          audioUrl: question.audioUrl,
          rich: question.isRichPrompt,
        ),

        SizedBox(height: 18.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _leftItems),

            SizedBox(width: 10.w),

            Expanded(child: _rightItems),
          ],
        ),
      ],
    );
  }

  Widget get _leftItems => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: question.leftItems
        .map(
          (TestMatchItemModel item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: TestPairTile(
              text: item.text,
              imageUrl: item.imageUrl,
              audioUrl: item.audioUrl,
              isSelected: selectedPromptId == item.id,
              badge: leftBadge(question, answer, item.id),
              onTap: () => onPromptTap(item.id),
            ),
          ),
        )
        .toList(growable: false),
  );

  Widget get _rightItems => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: orderedRights(question, matchOrder)
        .map(
          (TestMatchItemModel item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: TestPairTile(
              text: item.text,
              imageUrl: item.imageUrl,
              audioUrl: item.audioUrl,
              isMuted: true,
              isSelected: false,
              badge: rightBadge(question, answer, item.id),
              onTap: () => onMatchTap(item.id),
            ),
          ),
        )
        .toList(growable: false),
  );
}
