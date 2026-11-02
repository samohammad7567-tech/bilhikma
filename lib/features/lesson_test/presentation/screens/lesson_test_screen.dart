import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/lesson_test_cubit.dart';
import '../refactor/lesson_test_args.dart';
import '../refactor/lesson_test_body.dart';

class LessonTestScreen extends StatefulWidget {
  const LessonTestScreen({required this.args, super.key});

  final LessonTestArgs args;

  @override
  State<LessonTestScreen> createState() => _LessonTestScreenState();
}

class _LessonTestScreenState extends State<LessonTestScreen> {
  bool _timeUpHandled = false;

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
          builder: (BuildContext context, LessonTestState state) =>
              AppSectionScaffold(
                title: _title(state),
                child: LessonTestBody(
                  onBackToLessons: () => Navigator.of(context).pop(),
                ),
              ),
        ),
      ),
    );
  }

  String _title(LessonTestState state) {
    if (state.isResult) return 'test_result'.tr();
    if (state.isRunning) return 'lesson_test'.tr();
    return 'test_start'.tr();
  }

  void _handleState(BuildContext context, LessonTestState state) {
    if (_timeUpHandled) return;

    if (state.didTimeOut) {
      _timeUpHandled = true;
      AppToast.show(context, LangKeys.quizTimeUp.tr());
      Navigator.of(context).maybePop();
      return;
    }

    final String? key = state.messageKey;
    if (key != null) AppToast.show(context, key.tr());
  }
}
