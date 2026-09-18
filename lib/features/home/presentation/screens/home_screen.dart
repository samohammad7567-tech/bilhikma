import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../../core/routing/subject_content_args.dart';
import '../../data/models/resume_lesson_model.dart';
import '../../../../core/models/subject_model.dart';
import '../cubit/home_cubit.dart';
import '../refactor/home_screen_body.dart';
import '../../../../core/widgets/app_toast.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onMenuTap,
    this.onNotificationsTap,
    this.onViewAllSubjects,
    this.onSubjectTap,
    this.onLiveSessionTap,
    this.onResumeLessonTap,
    this.unreadNotifications = 0,
    this.onRefreshNotifications,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onViewAllSubjects;
  final ValueChanged<SubjectModel>? onSubjectTap;
  final ValueChanged<LiveSessionModel>? onLiveSessionTap;
  final ValueChanged<ResumeLessonModel>? onResumeLessonTap;

  final int unreadNotifications;

  final Future<void> Function()? onRefreshNotifications;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => getIt<HomeCubit>(),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (HomeState previous, HomeState current) =>
            current.errorKey != null && current.overview != null,
        listener: _showRefreshError,
        child: Builder(
          builder: (BuildContext context) => HomeScreenBody(
            unreadNotifications: unreadNotifications,
            onRefreshNotifications: onRefreshNotifications,
            onMenuTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            onNotificationsTap:
                onNotificationsTap ??
                () => Navigator.of(context).pushNamed(AppRoutes.notification),
            onViewAllSubjects: onViewAllSubjects,
            onSubjectTap:
                onSubjectTap ??
                (SubjectModel subject) => Navigator.of(context).pushNamed(
                  AppRoutes.subjectContent,
                  arguments: SubjectContentArgs(
                    categorySubjectId: subject.categorySubjectId,
                  ),
                ),

            onLiveSessionTap:
                onLiveSessionTap ??
                (LiveSessionModel session) => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.livePlayer, arguments: session),
            onResumeLessonTap:
                onResumeLessonTap ??
                (ResumeLessonModel lesson) => _openLesson(context, lesson),
          ),
        ),
      ),
    );
  }

  Future<void> _openLesson(
    BuildContext context,
    ResumeLessonModel lesson,
  ) async {
    final HomeCubit cubit = context.read<HomeCubit>();

    await Navigator.of(context).pushNamed(
      AppRoutes.lessonDetail,
      arguments: LessonDetailArgs(id: lesson.contentId, type: lesson.type),
    );
    await cubit.refresh();
  }

  void _showRefreshError(BuildContext context, HomeState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
