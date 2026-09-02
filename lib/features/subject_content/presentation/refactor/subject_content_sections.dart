import 'package:flutter/material.dart';
import '../../../../core/enums/lesson_category_enum.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../cubit/subject_content_cubit.dart';
import '../widgets/subject_lessons_section.dart';
import '../widgets/subject_live_sessions_section.dart';
import '../widgets/subject_albums_section.dart';
import '../widgets/subject_books_section.dart';

class SubjectContentSection extends StatelessWidget {
  const SubjectContentSection({
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
  Widget build(BuildContext context) => switch (state.selectedCategory) {
    LessonCategory.lessons => SubjectLessonsSection(
      lessons: state.lessons,
      onLessonTap: onLessonTap,
    ),
    LessonCategory.live => SubjectLiveSessionsSection(
      sessions: state.liveSessions,
      onWatch: onWatchLive,
      onRemind: onRemindLive,
    ),
    LessonCategory.books => SubjectBooksSection(
      books: state.books,
      downloadingBookId: state.downloadingBookId,
      previewingBookId: state.previewingBookId,
      downloadedBookIds: state.downloadedBookIds,
      onDownload: onDownloadBook,
      onPreview: onPreviewBook,
    ),
    LessonCategory.pictures => SubjectAlbumsSection(
      albums: state.albums,
      onAlbumTap: onAlbumTap,
    ),
  };
}
