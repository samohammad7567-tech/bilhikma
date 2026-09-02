import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/live_session_model.dart';
import '../../data/models/resume_lesson_model.dart';
import '../../../../core/models/subject_model.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_top_bar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../widgets/home_sections.dart';

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({
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
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: HomeTopBar(
              onMenuTap: onMenuTap,
              onNotificationsTap: onNotificationsTap,
              unreadNotifications: unreadNotifications,
            ),
          ),

          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (BuildContext context, HomeState state) {
                if (state.isFirstLoad) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.overview == null) {
                  return AppErrorView(
                    errorKey: state.errorKey,
                    onRetry: context.read<HomeCubit>().loadOverview,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => Future.wait<void>(<Future<void>>[
                    context.read<HomeCubit>().refresh(),
                    if (onRefreshNotifications != null)
                      onRefreshNotifications!(),
                  ]),
                  child: HomeSections(
                    state: state,
                    onViewAllSubjects: onViewAllSubjects,
                    onSubjectTap: onSubjectTap,
                    onLiveSessionTap: onLiveSessionTap,
                    onResumeLessonTap: onResumeLessonTap,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
