import 'package:flutter/material.dart';

import '../../data/models/quiz_attempt_model.dart';
import 'lesson_test_result_scroll_view.dart';
import 'test_result_action_bar.dart';

class LessonTestResultView extends StatelessWidget {
  const LessonTestResultView({
    required this.result,
    required this.showReview,
    required this.onBackToLesson,
    super.key,
  });

  final QuizAttemptModel result;
  final bool showReview;
  final VoidCallback onBackToLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: LessonTestResultScrollView(
            result: result,
            showReview: showReview,
          ),
        ),
        TestResultActionBar(onBackToLesson: onBackToLesson),
      ],
    );
  }
}
