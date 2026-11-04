import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';
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
              isSelected: selectedPromptId == item.id,
              badge: _leftBadge(item.id),
              onTap: () => onPromptTap(item.id),
            ),
          ),
        )
        .toList(growable: false),
  );

  Widget get _rightItems => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: _orderedRights
        .map(
          (TestMatchItemModel item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: TestPairTile(
              text: item.text,
              isMuted: true,
              isSelected: false,
              badge: _rightBadge(item.id),
              onTap: () => onMatchTap(item.id),
            ),
          ),
        )
        .toList(growable: false),
  );

  List<TestMatchItemModel> get _orderedRights {
    if (matchOrder.isEmpty) return question.rightItems;

    final List<TestMatchItemModel> ordered = <TestMatchItemModel>[];

    for (final String rightId in matchOrder) {
      for (final TestMatchItemModel item in question.rightItems) {
        if (item.id == rightId) ordered.add(item);
      }
    }

    return ordered.length == question.rightItems.length
        ? ordered
        : question.rightItems;
  }

  int? _leftBadge(String leftId) {
    final int index = question.leftItems.indexWhere(
      (TestMatchItemModel item) => item.id == leftId,
    );
    if (index == -1) return null;

    final bool isMatched = answer.matches.values.any(
      (String value) => value == leftId,
    );

    return isMatched ? index + 1 : null;
  }

  int? _rightBadge(String rightId) {
    final String? leftId = answer.leftForRight(rightId);
    if (leftId == null) return null;

    final int index = question.leftItems.indexWhere(
      (TestMatchItemModel item) => item.id == leftId,
    );
    return index == -1 ? null : index + 1;
  }
}
