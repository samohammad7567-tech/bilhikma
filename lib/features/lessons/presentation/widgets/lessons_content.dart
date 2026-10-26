import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_fade_slide_in.dart';
import '../../../../core/widgets/app_state_switcher.dart';
import '../../../../core/models/subject_content_model.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/lessons_cubit.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../../../../core/widgets/loading/app_inline_loader.dart';
import '../../../../core/widgets/loading/skeletons/lesson_cards_skeleton.dart';
import 'lesson_media_tabs.dart';
import 'lessons_skeleton.dart';
import '../../../../core/widgets/lesson_subject_header.dart';

class LessonsContent extends StatelessWidget {
  const LessonsContent({required this.state, this.onLessonTap, super.key});

  final LessonsState state;
  final ValueChanged<LessonModel>? onLessonTap;

  @override
  Widget build(BuildContext context) =>
      AppStateSwitcher(child: _content(context));

  Widget _content(BuildContext context) {
    if (state.isFirstLoad) return const LessonsSkeleton();

    final SubjectContentModel? subject = state.subject;
    if (subject == null) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<LessonsCubit>().load,
      );
    }

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

          AppStateSwitcher(child: _lessons(context)),

          if (state.hasMore && !state.isLoading) _loadMore(context),
        ],
      ),
    );
  }

  Widget _lessons(BuildContext context) {
    // A type switch loads a different set, so the old cards are replaced rather
    // than left standing — but by skeletons of the same height, so the list
    // keeps its extent and the scroll position holds.
    if (state.isLoading) return const LessonCardsSkeleton();

    final List<LessonModel> lessons = state.lessons;

    if (lessons.isEmpty) {
      return const AppEmptyView(
        icon: Icons.menu_book_outlined,
        messageKey: 'no_lessons_in_section',
      );
    }

    return Column(
      children: <Widget>[
        for (int index = 0; index < lessons.length; index++)
          AppFadeSlideIn(
            index: index,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: LessonCard(
                lesson: lessons[index],
                onTap: onLessonTap == null
                    ? null
                    : () => onLessonTap!(lessons[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _loadMore(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
    child: Center(
      child: state.isLoadingMore
          ? const AppInlineLoader()
          : TextButton(
              onPressed: context.read<LessonsCubit>().loadMore,
              child: Text('load_more'.tr()),
            ),
    ),
  );
}
