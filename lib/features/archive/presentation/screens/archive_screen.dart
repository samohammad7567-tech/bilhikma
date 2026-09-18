import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/archive_cubit.dart';
import '../refactor/archive_body.dart';
import '../../../../core/widgets/app_toast.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key, this.onLessonTap, this.showBack = true});

  final ValueChanged<LessonModel>? onLessonTap;

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ArchiveCubit>(
      create: (_) => getIt<ArchiveCubit>(),
      child: BlocListener<ArchiveCubit, ArchiveState>(
        listenWhen: (ArchiveState previous, ArchiveState current) =>
            current.errorKey != null && current.items != null,
        listener: _showRefreshError,
        child: AppSectionScaffold(
          title: context.tr('saved_items'),
          showBack: showBack,
          showMenu: !showBack,
          child: Builder(
            builder: (BuildContext context) => ArchiveBody(
              onLessonTap: (LessonModel lesson) => _openLesson(context, lesson),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, LessonModel lesson) async {
    final ValueChanged<LessonModel>? onLessonTap = this.onLessonTap;
    if (onLessonTap != null) {
      onLessonTap(lesson);
      return;
    }

    final ArchiveCubit cubit = context.read<ArchiveCubit>();

    await Navigator.of(context).pushNamed(
      AppRoutes.lessonDetail,
      arguments: LessonDetailArgs.fromLesson(lesson),
    );
    await cubit.silentRefresh();
  }

  void _showRefreshError(BuildContext context, ArchiveState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
