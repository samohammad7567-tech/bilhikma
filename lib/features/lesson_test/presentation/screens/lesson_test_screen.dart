import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/routing/subject_content_args.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/lesson_test_cubit.dart';
import '../refactor/lesson_test_args.dart';
import '../refactor/lesson_test_body.dart';
import '../widgets/quiz_leave_dialog.dart';

class LessonTestScreen extends StatefulWidget {
  const LessonTestScreen({required this.args, super.key});

  final LessonTestArgs args;

  @override
  State<LessonTestScreen> createState() => _LessonTestScreenState();
}

class _LessonTestScreenState extends State<LessonTestScreen>
    with WidgetsBindingObserver {
  bool _timeUpHandled = false;
  bool _leaveRequested = false;
  bool _leavingResult = false;

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
      if (cubit.state.isRunning) unawaited(cubit.reopenCurrentQuestion());
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
        listener: _handleState,
        child: BlocBuilder<LessonTestCubit, LessonTestState>(
          builder: (BuildContext context, LessonTestState state) {
            final LessonTestCubit cubit = context.read<LessonTestCubit>();

            return PopScope(
              canPop: !state.isRunning && !state.isResult,
              onPopInvokedWithResult: (bool didPop, Object? _) async {
                if (didPop) return;
                if (state.isResult) {
                  if (widget.args.popOnResultBack) {
                    Navigator.of(context).pop();
                    return;
                  }
                  unawaited(_goToSubjectContent());
                  return;
                }
                if (!state.isRunning) {
                  Navigator.of(context).pop();
                  return;
                }
                if (_leaveRequested) return;
                _leaveRequested = true;
                try {
                  await cubit.flushAnswers();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                } finally {
                  _leaveRequested = false;
                }
              },
              child: AppSectionScaffold(
                title: _title(state),
                onBack: () => _handleBack(cubit, state),
                child: LessonTestBody(
                  onBackToLesson: () => _backToLesson(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _title(LessonTestState state) {
    if (widget.args.openResult) return 'test_result'.tr();
    if (state.isResult) return 'test_result'.tr();
    if (state.isRunning) return 'lesson_test'.tr();
    return 'test_start'.tr();
  }

  void _backToLesson(BuildContext context) {
    final LessonTestArgs args = widget.args;
    if (args.openLessonOnBack && args.lessonId > 0) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.lessonDetail,
        arguments: LessonDetailArgs(id: args.lessonId, type: args.contentType),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  void _handleBack(LessonTestCubit cubit, LessonTestState state) {
    if (state.isResult) {
      if (widget.args.popOnResultBack) {
        Navigator.of(context).pop();
        return;
      }
      unawaited(_goToSubjectContent());
      return;
    }

    if (!state.isRunning) {
      Navigator.of(context).pop();
      return;
    }

    unawaited(_leaveWithoutSubmit(cubit));
  }

  Future<void> _goToSubjectContent() async {
    if (_leavingResult) return;
    _leavingResult = true;

    int categorySubjectId = widget.args.categorySubjectId;
    if (categorySubjectId <= 0 && widget.args.lessonId > 0) {
      categorySubjectId = await context
          .read<LessonTestCubit>()
          .resolveCategorySubjectId();
    }

    if (!mounted) return;

    if (categorySubjectId > 0) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.subjectContent,
        (Route<dynamic> route) => route.isFirst,
        arguments: SubjectContentArgs(categorySubjectId: categorySubjectId),
      );
      return;
    }

    if (widget.args.lessonId > 0) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.lessonDetail,
        arguments: LessonDetailArgs(
          id: widget.args.lessonId,
          type: widget.args.contentType,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _leaveWithoutSubmit(LessonTestCubit cubit) async {
    if (_leaveRequested) return;

    final LessonTestState current = cubit.state;
    if (!current.isRunning || current.isSubmitting) return;

    _leaveRequested = true;

    try {
      await cubit.flushAnswers();
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      _leaveRequested = false;
    }
  }

  Future<void> _confirmLeave(LessonTestCubit cubit) async {
    if (_leaveRequested) return;

    final LessonTestState current = cubit.state;
    if (!current.isRunning || current.isSubmitting) return;

    _leaveRequested = true;

    try {
      final bool confirmed = await QuizLeaveDialog.show(context);
      if (!confirmed || !mounted) return;

      await cubit.flushAndLeave();
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      _leaveRequested = false;
    }
  }

  void _handleState(BuildContext context, LessonTestState state) {
    if (!state.didTimeOut) _timeUpHandled = false;

    if (!_timeUpHandled && state.didTimeOut) {
      _timeUpHandled = true;
      AppToast.show(context, LangKeys.quizTimeUp.tr());
    }

    final String? key = state.messageKey;
    if (key != null && !(key == LangKeys.quizTimeUp && _timeUpHandled)) {
      final String? message = state.errorKey == key ? state.errorMessage : null;
      AppToast.show(
        context,
        message?.trim().isNotEmpty == true ? message!.trim() : key.tr(),
      );
    }
  }
}
