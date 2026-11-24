import 'package:flutter/material.dart';

import '../../../../core/utils/screen_scale.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../refactor/lesson_test_result_body.dart';

class LessonTestResultScrollView extends StatelessWidget {
  const LessonTestResultScrollView({
    required this.result,
    required this.showReview,
    super.key,
  });

  final QuizAttemptModel result;
  final bool showReview;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        (16).w(context),
        (4).h(context),
        (16).w(context),
        (16).h(context),
      ),
      child: LessonTestResultBody(result: result, showReview: showReview),
    );
  }
}
