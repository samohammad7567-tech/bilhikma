import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../cubit/subject_content_cubit.dart';
import '../widgets/subject_content_content.dart';

class SubjectContentBody extends StatelessWidget {
  const SubjectContentBody({
    required this.onLessonTap,
    required this.onWatchLive,
    required this.onRemindLive,
    required this.onDownloadBook,
    required this.onCancelBookDownload,
    required this.onPreviewBook,
    required this.onOpenBook,
    required this.onAlbumTap,
    super.key,
  });

  final ValueChanged<LessonModel> onLessonTap;
  final ValueChanged<LiveSessionModel> onWatchLive;
  final ValueChanged<LiveSessionModel> onRemindLive;
  final ValueChanged<TextbookModel> onDownloadBook;
  final ValueChanged<TextbookModel> onCancelBookDownload;
  final ValueChanged<TextbookModel> onPreviewBook;
  final ValueChanged<TextbookModel> onOpenBook;
  final ValueChanged<MediaAlbumModel> onAlbumTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectContentCubit, SubjectContentState>(
      builder: (BuildContext context, SubjectContentState state) =>
          SubjectContentContent(
            state: state,
            onLessonTap: onLessonTap,
            onWatchLive: onWatchLive,
            onRemindLive: onRemindLive,
            onDownloadBook: onDownloadBook,
            onCancelBookDownload: onCancelBookDownload,
            onPreviewBook: onPreviewBook,
            onOpenBook: onOpenBook,
            onAlbumTap: onAlbumTap,
          ),
    );
  }
}
