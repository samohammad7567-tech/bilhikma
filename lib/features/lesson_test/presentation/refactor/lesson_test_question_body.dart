import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_question_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/test_nav_buttons.dart';
import '../widgets/test_progress_header.dart';
import 'test_question_view.dart';

class LessonTestQuestionBody extends StatelessWidget {
  const LessonTestQuestionBody({
    required this.cubit,
    required this.state,
    required this.question,
    super.key,
  });

  final LessonTestCubit cubit;
  final LessonTestState state;
  final TestQuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TestProgressHeader(
          remaining: state.remaining,
          questionNumber: state.currentIndex + 1,
          questionCount: state.questionCount,
          progress: state.progress,
          questionRemaining: state.questionRemaining,
          questionElapsed: state.questionElapsed,
        ),

        SizedBox(height: 22.h),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 16.h),
            child: TestQuestionView(
              cubit: cubit,
              state: state,
              question: question,
            ),
          ),
        ),

        SizedBox(height: 12.h),

        TestNavButtons(
          isFirstQuestion: state.isFirstQuestion,
          isLastQuestion: state.isLastQuestion,
          onNext: cubit.goNext,
          onPrevious: cubit.goPrevious,
        ),
      ],
    );
  }
}
