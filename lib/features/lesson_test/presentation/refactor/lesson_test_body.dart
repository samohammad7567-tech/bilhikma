import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/test_result_action_bar.dart';
import 'lesson_test_intro_body.dart';
import 'lesson_test_question_body.dart';
import 'lesson_test_result_body.dart';

class LessonTestBody extends StatelessWidget {
  const LessonTestBody({required this.onBackToLesson, super.key});

  final VoidCallback onBackToLesson;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonTestCubit, LessonTestState>(
      builder: (BuildContext context, LessonTestState state) {
        final LessonTestCubit cubit = context.read<LessonTestCubit>();

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            message: state.errorMessage,
            onRetry: cubit.retry,
          );
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final LessonTestState viewState = state;

        return Padding(
          padding: state.isResult
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: _body(context, cubit, viewState),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    LessonTestCubit cubit,
    LessonTestState state,
  ) {
    switch (state.status) {
      case LessonTestStatus.initial:
      case LessonTestStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LessonTestStatus.failure:
        return AppErrorView(
          errorKey: state.errorKey,
          message: state.errorMessage,
          onRetry: cubit.retry,
        );

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
        if (state.didTimeOut) return _timeUp(context, cubit, state);
        if (!state.hasQuestions) return _empty;

        return LessonTestQuestionBody(
          cubit: cubit,
          state: state,
          question: state.currentQuestion!,
        );

      case LessonTestStatus.result:
        final QuizAttemptModel? result = state.result;
        if (result == null) return _empty;

        return Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                child: LessonTestResultBody(
                  result: result,
                  showReview:
                      (state.quiz?.showCorrectAnswers ?? false) ||
                      result.hasSolutions,
                ),
              ),
            ),
            TestResultActionBar(onBackToLesson: onBackToLesson),
          ],
        );
    }
  }

  Widget get _empty => const Center(
    child: AppEmptyView(
      icon: Icons.quiz_outlined,
      messageKey: 'no_test_questions',
    ),
  );

  Widget _timeUp(
    BuildContext context,
    LessonTestCubit cubit,
    LessonTestState state,
  ) {
    if (state.errorKey != null) {
      return AppErrorView(
        errorKey: state.errorKey,
        message: state.errorMessage,
        onRetry: () => cubit.submit(timedOut: true),
      );
    }

    if (state.isSubmitting) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.timer_off_outlined,
                size: 46.w,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 16.h),
              Text(LangKeys.quizTimeUp.tr(), textAlign: TextAlign.center),
              SizedBox(height: 18.h),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Center(
      child: AppEmptyView(
        icon: Icons.timer_off_outlined,
        messageKey: LangKeys.quizTimeUp,
      ),
    );
  }
}
