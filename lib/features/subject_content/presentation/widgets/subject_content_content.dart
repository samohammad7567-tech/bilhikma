import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/subject_content_model.dart';
import '../../../../core/widgets/lesson_category_chips.dart';
import '../../../../core/widgets/lesson_subject_header.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../cubit/subject_content_cubit.dart';
import '../refactor/subject_content_sections.dart';

class SubjectContentContent extends StatelessWidget {
  const SubjectContentContent({
    required this.state,
    required this.onLessonTap,
    required this.onWatchLive,
    required this.onRemindLive,
    required this.onDownloadBook,
    required this.onPreviewBook,
    required this.onAlbumTap,
    super.key,
  });

  final SubjectContentState state;
  final ValueChanged<LessonModel> onLessonTap;
  final ValueChanged<LiveSessionModel> onWatchLive;
  final ValueChanged<LiveSessionModel> onRemindLive;
  final ValueChanged<TextbookModel> onDownloadBook;
  final ValueChanged<TextbookModel> onPreviewBook;
  final ValueChanged<MediaAlbumModel> onAlbumTap;

  @override
  Widget build(BuildContext context) {
    if (state.isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    final SubjectContentModel? subject = state.subject;
    if (subject == null) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<SubjectContentCubit>().loadContent,
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<SubjectContentCubit>().refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),

            child: LessonSubjectHeader(subject: subject),
          ),

          SizedBox(height: 16.h),

          LessonCategoryChips(
            selected: state.selectedCategory,
            onSelected: context.read<SubjectContentCubit>().selectCategory,
          ),

          SizedBox(height: 16.h),

          SubjectContentSection(
            state: state,
            onLessonTap: onLessonTap,
            onWatchLive: onWatchLive,
            onRemindLive: onRemindLive,
            onDownloadBook: onDownloadBook,
            onPreviewBook: onPreviewBook,
            onAlbumTap: onAlbumTap,
          ),
        ],
      ),
    );
  }
}
