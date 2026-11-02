import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../cubit/lesson_test_cubit.dart';
import 'lesson_test_intro_body.dart';
import 'lesson_test_question_body.dart';
import 'lesson_test_result_body.dart';

class LessonTestBody extends StatelessWidget {
  const LessonTestBody({required this.onBackToLessons, super.key});

  final VoidCallback onBackToLessons;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonTestCubit, LessonTestState>(
      builder: (BuildContext context, LessonTestState state) {
        final LessonTestCubit cubit = context.read<LessonTestCubit>();

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadQuiz,
          );
        }

        if (state.isLoading) return const _IntroSkeleton();

        final LessonTestState viewState = state;

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: _body(cubit, viewState),
        );
      },
    );
  }

  Widget _body(LessonTestCubit cubit, LessonTestState state) {
    if (state.didTimeOut) return _timeUp;

    switch (state.status) {
      case LessonTestStatus.initial:
      case LessonTestStatus.loading:
        return const _IntroSkeleton();

      case LessonTestStatus.failure:
        return AppErrorView(errorKey: state.errorKey, onRetry: cubit.loadQuiz);

      case LessonTestStatus.ready:
      case LessonTestStatus.starting:
        if ((state.quiz?.questionCount ?? 0) == 0) return _empty;

        return SingleChildScrollView(
          child: LessonTestIntroBody(
            cubit: cubit,
            state: state,
            onStart: cubit.startAttempt,
          ),
        );

      case LessonTestStatus.running:
      case LessonTestStatus.submitting:
        if (!state.hasQuestions) return _empty;

        return LessonTestQuestionBody(
          cubit: cubit,
          state: state,
          question: state.currentQuestion!,
        );

      case LessonTestStatus.result:
        final QuizAttemptModel? result = state.result;
        if (result == null) return _empty;

        return SingleChildScrollView(
          child: LessonTestResultBody(
            result: result,
            showReview: state.quiz?.showCorrectAnswers ?? false,
            onBackToLessons: onBackToLessons,
          ),
        );
    }
  }

  Widget get _empty => const Center(
    child: AppEmptyView(
      icon: Icons.quiz_outlined,
      messageKey: 'no_test_questions',
    ),
  );

  Widget get _timeUp => const Center(
    child: AppEmptyView(
      icon: Icons.timer_off_outlined,
      messageKey: LangKeys.quizTimeUp,
    ),
  );
}

class _IntroSkeleton extends StatelessWidget {
  const _IntroSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    Widget line({required double width, double height = 16}) => Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        children: <Widget>[
          SizedBox(height: 40.h),
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(height: 24.h),
          line(width: 180, height: 22),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            height: 130.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 18.h),
          line(width: 220),
          SizedBox(height: 40.h),
          Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }
}
