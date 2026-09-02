import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/drawer/presentation/refactor/app_drawer.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../textbooks/presentation/screens/book_preview_screen.dart';
import '../cubit/subject_content_cubit.dart';
import '../../../../core/routing/subject_content_args.dart';
import '../refactor/subject_content_body.dart';
import '../../../../core/widgets/app_toast.dart';

class SubjectContentScreen extends StatelessWidget {
  const SubjectContentScreen({required this.args, super.key});

  final SubjectContentArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubjectContentCubit>(
      create: (_) => getIt<SubjectContentCubit>(param1: args.categorySubjectId),
      child: BlocListener<SubjectContentCubit, SubjectContentState>(
        listenWhen:
            (SubjectContentState previous, SubjectContentState current) =>
                current.messageKey != null ||
                (current.errorKey != null && current.content != null),
        listener: _showMessage,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          drawer: const AppDrawer(),
          body: Builder(
            builder: (BuildContext context) => SubjectContentBody(
              onBack: () => Navigator.of(context).pop(),
              onMenuTap: () => Scaffold.of(context).openDrawer(),
              onLessonTap: (LessonModel lesson) => _openLesson(context, lesson),

              onWatchLive: (LiveSessionModel session) => Navigator.of(
                context,
              ).pushNamed(AppRoutes.livePlayer, arguments: session),
              onRemindLive: (LiveSessionModel session) =>
                  _report(context, 'reminder_saved'),
              onDownloadBook: (TextbookModel book) =>
                  context.read<SubjectContentCubit>().downloadBook(book),
              onPreviewBook: (TextbookModel book) =>
                  _previewBook(context, book),

              onAlbumTap: (MediaAlbumModel album) => Navigator.of(
                context,
              ).pushNamed(AppRoutes.pictures, arguments: album.id),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _previewBook(BuildContext context, TextbookModel book) async {
    final NavigatorState navigator = Navigator.of(context);
    final String? path = await context.read<SubjectContentCubit>().previewBook(
      book,
    );

    if (path == null) return;

    navigator.pushNamed(
      AppRoutes.bookPreview,
      arguments: BookPreviewArgs(
        filePath: path,
        title: book.title,
        contentId: book.id,
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, LessonModel lesson) async {
    final SubjectContentCubit cubit = context.read<SubjectContentCubit>();

    await Navigator.of(context).pushNamed(
      AppRoutes.lessonDetail,
      arguments: LessonDetailArgs.fromLesson(lesson),
    );

    await cubit.reloadAfterLesson();
  }

  void _report(BuildContext context, String messageKey) =>
      context.read<SubjectContentCubit>().reportMessage(messageKey);

  void _showMessage(BuildContext context, SubjectContentState state) {
    final String? key = state.messageKey ?? state.errorKey;
    if (key == null) return;

    if (state.messageKey == null) {
      AppToast.error(context, key.tr());
      return;
    }

    AppToast.show(context, key.tr());
  }
}
