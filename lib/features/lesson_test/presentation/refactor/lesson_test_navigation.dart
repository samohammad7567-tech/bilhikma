import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/routing/subject_content_args.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/lesson_test_cubit.dart';
import '../screens/lesson_test_screen.dart';
import 'lesson_test_args.dart';

mixin LessonTestNavigation on State<LessonTestScreen> {
  bool _timeUpHandled = false;
  bool _leaveRequested = false;
  bool _leavingResult = false;

  String titleOf(LessonTestState state) {
    if (widget.args.openResult) return LangKeys.testResult.tr();
    if (state.isResult) return LangKeys.testResult.tr();
    if (state.isRunning || (state.hasFailed && state.attempt != null)) {
      return LangKeys.lessonTest.tr();
    }
    return LangKeys.testStart.tr();
  }

  void backToLesson(BuildContext context) {
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

  void handleBack(LessonTestCubit cubit, LessonTestState state) {
    if (!state.isRunning) {
      unawaited(handlePop(cubit, state));
      return;
    }
    unawaited(leaveWithoutSubmit(cubit));
  }

  Future<void> handlePop(LessonTestCubit cubit, LessonTestState state) async {
    if (state.isResult) {
      if (widget.args.popOnResultBack) {
        Navigator.of(context).pop();
        return;
      }
      await goToSubjectContent();
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
  }

  Future<void> goToSubjectContent() async {
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

  Future<void> leaveWithoutSubmit(LessonTestCubit cubit) async {
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

  void handleState(BuildContext context, LessonTestState state) {
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
