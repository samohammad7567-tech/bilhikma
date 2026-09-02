import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/subject_content_model.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/lessons_cubit.dart';
import '../../../../core/widgets/lesson_card.dart';
import 'lesson_media_tabs.dart';
import '../../../../core/widgets/lesson_subject_header.dart';

class LessonsContent extends StatelessWidget {
  const LessonsContent({required this.state, this.onLessonTap, super.key});

  final LessonsState state;
  final ValueChanged<LessonModel>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    if (state.isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    final SubjectContentModel? subject = state.subject;
    if (subject == null) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<LessonsCubit>().load,
      );
    }

    final List<LessonModel> lessons = state.lessons;

    return RefreshIndicator(
      onRefresh: context.read<LessonsCubit>().refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: LessonSubjectHeader(subject: subject),
          ),

          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: LessonMediaTabs(
              selected: state.selectedType,
              onSelected: context.read<LessonsCubit>().selectType,
            ),
          ),

          SizedBox(height: 16.h),

          if (state.isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (lessons.isEmpty)
            const AppEmptyView(
              icon: Icons.menu_book_outlined,
              messageKey: 'no_lessons_in_section',
            )
          else ...<Widget>[
            for (final LessonModel lesson in lessons)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: LessonCard(
                  lesson: lesson,
                  onTap: onLessonTap == null
                      ? null
                      : () => onLessonTap!(lesson),
                ),
              ),

            if (state.hasMore)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Center(
                  child: state.isLoadingMore
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: context.read<LessonsCubit>().loadMore,
                          child: Text('view_all'.tr()),
                        ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
