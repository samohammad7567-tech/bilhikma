import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/lesson_test_cubit.dart';
import '../refactor/lesson_test_args.dart';
import '../refactor/lesson_test_body.dart';
import '../../../../core/widgets/app_toast.dart';

class LessonTestScreen extends StatelessWidget {
  const LessonTestScreen({required this.args, super.key, this.onNextLesson});

  final LessonTestArgs args;

  final VoidCallback? onNextLesson;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonTestCubit>(
      create: (_) => LessonTestCubit(lessonId: args.lessonId),
      child: BlocListener<LessonTestCubit, LessonTestState>(
        listenWhen: (LessonTestState previous, LessonTestState current) =>
            current.messageKey != null,
        listener: _showMessage,
        child: BlocBuilder<LessonTestCubit, LessonTestState>(
          buildWhen: (LessonTestState previous, LessonTestState current) =>
              previous.phase != current.phase,
          builder: (BuildContext context, LessonTestState state) =>
              AppSectionScaffold(
                title: _title(state.phase),
                child: LessonTestBody(
                  onNextLesson: () => _goToNextLesson(context),
                  onBackToLessons: () => Navigator.of(context).pop(),
                ),
              ),
        ),
      ),
    );
  }

  String _title(LessonTestPhase phase) {
    switch (phase) {
      case LessonTestPhase.intro:
        return 'test_start'.tr();
      case LessonTestPhase.running:
        return 'lesson_test'.tr();
      case LessonTestPhase.result:
        return 'test_result'.tr();
    }
  }

  void _goToNextLesson(BuildContext context) {
    final VoidCallback? onNextLesson = this.onNextLesson;

    onNextLesson == null
        ? context.read<LessonTestCubit>().reportMessage('coming_soon')
        : onNextLesson();
  }

  void _showMessage(BuildContext context, LessonTestState state) {
    final String? key = state.messageKey;
    if (key == null) return;

    AppToast.show(context, key.tr());
  }
}
