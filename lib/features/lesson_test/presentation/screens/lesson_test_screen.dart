import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/lang_keys.dart';
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

class _LessonTestScreenState extends State<LessonTestScreen> {
  bool _timeUpHandled = false;
  bool _leaveRequested = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonTestCubit>(
      create: (_) => LessonTestCubit(lessonId: widget.args.lessonId),
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
              canPop: !state.isRunning,
              onPopInvokedWithResult: (bool didPop, Object? _) {
                if (didPop) return;
                unawaited(_confirmLeave(cubit));
              },
              child: AppSectionScaffold(
                title: _title(state),
                onBack: () => _handleBack(cubit, state),
                child: LessonTestBody(
                  onBackToLessons: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _title(LessonTestState state) {
    if (state.isResult) return 'test_result'.tr();
    if (state.isRunning) return 'lesson_test'.tr();
    return 'test_start'.tr();
  }

  void _handleBack(LessonTestCubit cubit, LessonTestState state) {
    if (!state.isRunning) {
      Navigator.of(context).pop();
      return;
    }

    unawaited(_confirmLeave(cubit));
  }

  Future<void> _confirmLeave(LessonTestCubit cubit) async {
    if (_leaveRequested) return;

    final LessonTestState current = cubit.state;
    if (!current.isRunning || current.isSubmitting) return;

    _leaveRequested = true;

    try {
      final bool confirmed = await QuizLeaveDialog.show(context);
      if (!confirmed || !mounted) return;

      final bool left = await cubit.submitAndLeave();
      if (!mounted || !left) return;

      Navigator.of(context).pop();
    } finally {
      _leaveRequested = false;
    }
  }

  void _handleState(BuildContext context, LessonTestState state) {
    if (_timeUpHandled) return;

    if (state.didTimeOut) {
      _timeUpHandled = true;
      AppToast.show(context, LangKeys.quizTimeUp.tr());
      Navigator.of(context).pop();
      return;
    }

    final String? key = state.messageKey;
    if (key != null) AppToast.show(context, key.tr());
  }
}
