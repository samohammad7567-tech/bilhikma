import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/lessons_cubit.dart';
import '../refactor/lessons_view_all_body.dart';
import '../../../../core/widgets/app_toast.dart';

class LessonsViewAllScreen extends StatelessWidget {
  const LessonsViewAllScreen({
    super.key,
    this.categorySubjectId = 0,
    this.onLessonTap,
  });

  final int categorySubjectId;
  final ValueChanged<LessonModel>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonsCubit>(
      create: (_) => getIt<LessonsCubit>(param1: categorySubjectId),
      child: BlocListener<LessonsCubit, LessonsState>(
        listenWhen: (LessonsState previous, LessonsState current) =>
            current.errorKey != null && current.subject != null,
        listener: _showRefreshError,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: LessonsViewAllBody(
            onBack: () => Navigator.of(context).pop(),
            onLessonTap: (LessonModel lesson) => _openLesson(context, lesson),
          ),
        ),
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, LessonModel lesson) async {
    if (onLessonTap != null) {
      onLessonTap!(lesson);
      return;
    }

    final LessonsCubit cubit = context.read<LessonsCubit>();

    await Navigator.of(context).pushNamed(
      AppRoutes.lessonDetail,
      arguments: LessonDetailArgs.fromLesson(lesson),
    );

    await cubit.refresh();
  }

  void _showRefreshError(BuildContext context, LessonsState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
