import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_question_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/question_locked_banner.dart';
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
    final bool locked = state.isCurrentQuestionLocked;
    final bool opening = state.openingQuestionId == question.id;

    return Column(
      children: <Widget>[
        TestProgressHeader(
          remaining: state.remaining,
          questionNumber: state.currentIndex + 1,
          questionCount: state.questionCount,
          progress: state.progress,
          saveStatus: state.saveStatus,
          showTotalTimer: state.hasTimeLimit,
        ),

        if (opening) LinearProgressIndicator(minHeight: 2.h),

        SizedBox(height: 22.h),

        if (locked &&
            !opening &&
            (state.isCurrentQuestionExpired ||
                state.openedQuestionIds.contains(question.id)))
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: const QuestionLockedBanner(),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 16.h),
            child: IgnorePointer(
              ignoring: locked,
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: TestQuestionView(
                  cubit: cubit,
                  state: state,
                  question: question,
                  questionRemaining: state.currentQuestionRemaining,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        TestNavButtons(
          isFirstQuestion: state.isFirstQuestion,
          isLastQuestion: state.isLastQuestion,
          isSubmitting: state.isSubmitting,
          onNext: cubit.goNext,
          onPrevious: cubit.goPrevious,
        ),
      ],
    );
  }
}
