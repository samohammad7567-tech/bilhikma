import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/paginated_result.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/download_progress.dart';
import '../../../../core/enums/lesson_category_enum.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/lessons_filter.dart';
import '../../../lessons/data/repos/lessons_repo.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../live_sessions/data/repos/live_sessions_repo.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../textbooks/data/repos/textbooks_repo.dart';
import '../../../../core/models/subject_content_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../../../gallery/data/repos/gallery_repo.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../../../textbooks/data/data_source/book_downloads_data_source.dart';
import '../../data/repos/subject_content_repo.dart';

part 'subject_content_state.dart';

class SubjectContentCubit extends Cubit<SubjectContentState> {
  SubjectContentCubit({
    required this.categorySubjectId,
    this.repo = const SubjectContentRepo(),
    this.lessonsRepo = const LessonsRepo(),
    this.liveRepo = const LiveSessionsRepo(),
    this.galleryRepo = const GalleryRepo(),
    TextbooksRepo? textbooksRepo,
  }) : textbooksRepo = textbooksRepo ?? TextbooksRepo(),
       super(
         SubjectContentState(bookDownloads: BookDownloadsDataSource.snapshot),
       ) {
    loadContent();
    DownloadedPdfsDataSource.revision.addListener(_onDownloadsChanged);
    BookDownloadsDataSource.active.addListener(_onActiveDownloadsChanged);
  }

  final int categorySubjectId;
  final SubjectContentRepo repo;
  final LessonsRepo lessonsRepo;
  final LiveSessionsRepo liveRepo;
  final GalleryRepo galleryRepo;
  final TextbooksRepo textbooksRepo;

  final Set<int> _ownDownloads = <int>{};

  @override
  Future<void> close() {
    DownloadedPdfsDataSource.revision.removeListener(_onDownloadsChanged);
    BookDownloadsDataSource.active.removeListener(_onActiveDownloadsChanged);
    return super.close();
  }

  Future<void> reloadAfterLesson() async {
    try {
      final SubjectContentModel content = await repo.fetchSubject(
        categorySubjectId,
      );
      if (isClosed) return;

      final PaginatedResult<LessonModel> lessons = await lessonsRepo
          .fetchLessons(
            LessonsFilter(categorySubjectId: categorySubjectId, perPage: 50),
          );
      if (isClosed) return;

      emit(state.copyWith(content: content, lessons: lessons.items));
    } catch (_) {}
  }

  Future<void> loadContent() async {
    emit(state.copyWith(status: SubjectContentStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final SubjectContentModel content = await repo.fetchSubject(
        categorySubjectId,
      );
      if (isClosed) return;

      final PaginatedResult<LessonModel> lessons = await lessonsRepo
          .fetchLessons(
            LessonsFilter(categorySubjectId: categorySubjectId, perPage: 50),
          );
      if (isClosed) return;

      emit(
        state.copyWith(
          status: SubjectContentStatus.success,
          content: content,
          lessons: lessons.items,
          clearError: true,
        ),
      );

      await _refreshDownloadedBooks();
      if (isClosed) return;
      _reportMissedFailures();

      try {
        final List<LiveSessionModel> sessions = await liveRepo.fetchSessions();
        if (isClosed) return;
        emit(state.copyWith(liveSessions: sessions));
      } catch (_) {}

      try {
        final List<MediaAlbumModel> albums = await galleryRepo.fetchAlbums(
          categorySubjectId: categorySubjectId,
        );
        if (isClosed) return;
        emit(state.copyWith(albums: albums));
      } catch (_) {}
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SubjectContentStatus.failure,
          errorKey: error.key,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SubjectContentStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void selectCategory(LessonCategory category) {
    if (category == state.selectedCategory) return;
    emit(state.copyWith(selectedCategory: category));
  }

  Future<void> downloadBook(TextbookModel book) async {
    if (state.isBookBusy(book.id) || state.isBookDownloaded(book.id)) return;

    _ownDownloads.add(book.id);

    await _runBookAction(() async {
      final File file = await textbooksRepo.downloadTextbook(book);
      if (isClosed) return 'book_download_failed';

      return file.existsSync() ? 'book_downloaded' : 'book_download_failed';
    }, isPreview: false);
    _ownDownloads.remove(book.id);
    BookDownloadsDataSource.takeMissedFailure(book.id);

    await _refreshDownloadedBooks();
  }

  void _onActiveDownloadsChanged() {
    if (isClosed) return;

    final Map<int, DownloadProgress> next = BookDownloadsDataSource.snapshot;
    final Set<int> orphaned = state.bookDownloads.keys.toSet()
      ..removeAll(next.keys)
      ..removeAll(_ownDownloads);

    emit(state.copyWith(bookDownloads: next));

    for (final int bookId in orphaned) {
      final String? key = BookDownloadsDataSource.takeMissedFailure(bookId);
      if (key == null) continue;

      emit(state.copyWith(messageKey: key));
      break;
    }
  }

  void _reportMissedFailures() {
    for (final TextbookModel book in state.books) {
      final String? key = BookDownloadsDataSource.takeMissedFailure(book.id);
      if (key == null) continue;

      emit(state.copyWith(messageKey: key));
      return;
    }
  }

  void _onDownloadsChanged() => unawaited(_refreshDownloadedBooks());

  Future<void> _refreshDownloadedBooks() async {
    final List<TextbookModel> books = state.books;
    if (books.isEmpty) return;

    final Set<int> downloaded = await textbooksRepo.downloadedBookIds(
      books.map((TextbookModel book) => book.id),
    );
    if (isClosed) return;

    emit(state.copyWith(downloadedBookIds: downloaded));
  }

  /// Asks the backend for a signed URL so the reader can open the book
  /// straight from the network, with no download step first.
  Future<String?> previewBook(TextbookModel book) async {
    if (state.isBookBusy(book.id)) return null;

    emit(state.copyWith(previewingBookId: book.id, resetPreviewProgress: true));

    String? url;

    await _runBookAction(() async {
      final String link = await textbooksRepo.previewUrl(book);
      if (link.trim().isEmpty) return 'book_download_failed';

      url = link;
      return null;
    }, isPreview: true);

    return url;
  }

  /// Opens the copy already on the device: no network, no download. If the
  /// file has been deleted behind our back, the card falls back to Download.
  Future<String?> openBook(TextbookModel book) async {
    if (state.isBookBusy(book.id)) return null;

    emit(state.copyWith(previewingBookId: book.id, resetPreviewProgress: true));

    String? path;

    await _runBookAction(() async {
      final File? saved = await textbooksRepo.downloadedFile(book);
      if (saved == null) {
        await _refreshDownloadedBooks();

        return 'reader_load_failed';
      }

      path = saved.path;
      return null;
    }, isPreview: true);

    return path;
  }

  Future<void> _runBookAction(
    Future<String?> Function() action, {
    required bool isPreview,
  }) async {
    String? messageKey;

    try {
      messageKey = await action();
    } on AppException catch (error) {
      messageKey = error.key;
    } catch (error) {
      messageKey = ErrorMapper.map(error);
    }

    if (isClosed) return;

    emit(
      state.copyWith(
        messageKey: messageKey,
        clearPreviewingBook: isPreview,
        resetPreviewProgress: isPreview,
      ),
    );
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));
}
