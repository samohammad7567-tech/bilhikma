import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/lesson_test_cubit.dart';
import '../refactor/lesson_test_args.dart';
import '../refactor/lesson_test_body.dart';

class LessonTestScreen extends StatelessWidget {
  const LessonTestScreen({required this.args, super.key, this.onNextLesson});

  final LessonTestArgs args;

  final ValueChanged<int>? onNextLesson;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonTestCubit>(
      create: (_) => LessonTestCubit(
        lessonId: args.lessonId,
        categorySubjectId: args.categorySubjectId,
      ),
      child: BlocListener<LessonTestCubit, LessonTestState>(
        listenWhen: (LessonTestState previous, LessonTestState current) =>
            current.messageKey != null &&
            current.messageKey != previous.messageKey,
        listener: _showMessage,
        child: BlocBuilder<LessonTestCubit, LessonTestState>(
          builder: (BuildContext context, LessonTestState state) =>
              AppSectionScaffold(
                title: _title(state),
                child: LessonTestBody(
                  onNextLesson: onNextLesson,
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

  void _showMessage(BuildContext context, LessonTestState state) {
    final String? key = state.messageKey;
    if (key == null) return;

    AppToast.show(context, key.tr());
  }
}
