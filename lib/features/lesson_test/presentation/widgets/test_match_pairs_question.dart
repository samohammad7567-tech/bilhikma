import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_pair_model.dart';
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
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final List<String> matchOrder;

  final ValueChanged<String> onPromptTap;
  final ValueChanged<String> onMatchTap;

  final String? selectedPromptId;

  @override
  Widget build(BuildContext context) {
    final List<String> linkOrder = answer.pairs.keys.toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(prompt: question.prompt),

        SizedBox(height: 18.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _prompts(linkOrder)),

            SizedBox(width: 10.w),

            Expanded(child: _matches(linkOrder)),
          ],
        ),
      ],
    );
  }

  Widget _prompts(List<String> linkOrder) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: question.pairs
        .map(
          (TestPairModel pair) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: TestPairTile(
              text: pair.prompt,
              isSelected: selectedPromptId == pair.id,
              badge: _badgeOf(linkOrder, pair.id),
              onTap: () => onPromptTap(pair.id),
            ),
          ),
        )
        .toList(growable: false),
  );

  Widget _matches(List<String> linkOrder) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: _orderedMatches
        .map(
          (TestPairModel pair) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: TestPairTile(
              text: pair.match,
              isMuted: true,
              isSelected: false,
              badge: _badgeOfMatch(linkOrder, pair.id),
              onTap: () => onMatchTap(pair.id),
            ),
          ),
        )
        .toList(growable: false),
  );

  List<TestPairModel> get _orderedMatches {
    if (matchOrder.isEmpty) return question.pairs;

    final List<TestPairModel> ordered = <TestPairModel>[];

    for (final String pairId in matchOrder) {
      for (final TestPairModel pair in question.pairs) {
        if (pair.id == pairId) ordered.add(pair);
      }
    }

    return ordered.length == question.pairs.length ? ordered : question.pairs;
  }

  int? _badgeOf(List<String> linkOrder, String promptId) {
    final int index = linkOrder.indexOf(promptId);
    return index == -1 ? null : index + 1;
  }

  int? _badgeOfMatch(List<String> linkOrder, String matchId) {
    for (int index = 0; index < linkOrder.length; index++) {
      if (answer.matchOf(linkOrder[index]) == matchId) return index + 1;
    }
    return null;
  }
}
