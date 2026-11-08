import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/lesson_test_cubit.dart';
import '../refactor/lesson_test_args.dart';
import '../refactor/lesson_test_body.dart';
import '../refactor/lesson_test_navigation.dart';

class LessonTestScreen extends StatefulWidget {
  const LessonTestScreen({required this.args, super.key});

  final LessonTestArgs args;

  @override
  State<LessonTestScreen> createState() => _LessonTestScreenState();
}

class _LessonTestScreenState extends State<LessonTestScreen>
    with WidgetsBindingObserver, LessonTestNavigation {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final LessonTestCubit cubit = context.read<LessonTestCubit>();

    if (state == AppLifecycleState.resumed) {
      if (cubit.state.isRunning) {
        unawaited(cubit.reopenCurrentQuestion());
        unawaited(cubit.flushAnswers());
      }
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(cubit.flushAnswers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonTestCubit>(
      create: (_) => LessonTestCubit(
        lessonId: widget.args.lessonId,
        resultOnly: widget.args.openResult,
        initialQuizId: widget.args.quizId,
        initialAttemptId: widget.args.attemptId,
      ),
      child: BlocListener<LessonTestCubit, LessonTestState>(
        listenWhen: (LessonTestState previous, LessonTestState current) =>
            (current.didTimeOut && !previous.didTimeOut) ||
            (current.messageKey != null &&
                current.messageKey != previous.messageKey),
        listener: handleState,
        child: BlocBuilder<LessonTestCubit, LessonTestState>(
          builder: (BuildContext context, LessonTestState state) {
            final LessonTestCubit cubit = context.read<LessonTestCubit>();

            return PopScope(
              canPop: !state.isRunning && !state.isResult,
              onPopInvokedWithResult: (bool didPop, Object? _) async {
                if (didPop) return;
                await handlePop(cubit, state);
              },
              child: AppSectionScaffold(
                title: titleOf(state),
                onBack: () => handleBack(cubit, state),
                child: LessonTestBody(
                  onBackToLesson: () => backToLesson(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
