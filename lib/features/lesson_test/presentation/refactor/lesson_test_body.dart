import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/lesson_test_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_result_model.dart';
import '../cubit/lesson_test_cubit.dart';
import 'lesson_test_intro_body.dart';
import 'lesson_test_question_body.dart';
import 'lesson_test_result_body.dart';

class LessonTestBody extends StatelessWidget {
  const LessonTestBody({
    required this.onNextLesson,
    required this.onBackToLessons,
    super.key,
  });

  final VoidCallback onNextLesson;
  final VoidCallback onBackToLessons;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonTestCubit, LessonTestState>(
      builder: (BuildContext context, LessonTestState state) {
        final LessonTestCubit cubit = context.read<LessonTestCubit>();

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadTest,
          );
        }

        final LessonTestModel? test = state.test;
        if (test == null || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!test.hasQuestions) {
          return const Center(
            child: AppEmptyView(
              icon: Icons.quiz_outlined,
              messageKey: 'no_test_questions',
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: _phase(cubit, state, test),
        );
      },
    );
  }

  Widget _phase(
    LessonTestCubit cubit,
    LessonTestState state,
    LessonTestModel test,
  ) {
    switch (state.phase) {
      case LessonTestPhase.intro:
        return SingleChildScrollView(
          child: LessonTestIntroBody(test: test, onStart: cubit.startTest),
        );

      case LessonTestPhase.running:
        final TestQuestionModel? question = state.currentQuestion;
        if (question == null) return const SizedBox.shrink();

        return LessonTestQuestionBody(
          cubit: cubit,
          state: state,
          question: question,
        );

      case LessonTestPhase.result:
        final TestResultModel? result = state.result;
        if (result == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          child: LessonTestResultBody(
            result: result,
            onNextLesson: onNextLesson,
            onBackToLessons: onBackToLessons,
          ),
        );
    }
  }
}
