part of 'subject_content_cubit.dart';

enum SubjectContentStatus { initial, loading, success, failure }

final class SubjectContentState {
  const SubjectContentState({
    this.status = SubjectContentStatus.initial,
    this.selectedCategory = LessonCategory.lessons,
    this.content,
    this.lessons = const <LessonModel>[],
    this.liveSessions = const <LiveSessionModel>[],
    this.albums = const <MediaAlbumModel>[],
    this.bookDownloads = const <int, DownloadProgress>{},
    this.previewingBookId,
    this.previewProgress = DownloadProgress.none,
    this.downloadedBookIds = const <int>{},
    this.errorKey,
    this.messageKey,
  });

  final SubjectContentStatus status;
  final LessonCategory selectedCategory;

  final SubjectContentModel? content;
  final List<LessonModel> lessons;

  final List<LiveSessionModel> liveSessions;

  final List<MediaAlbumModel> albums;

  /// Mirrors the app wide registry, so a download started on an earlier visit
  /// to this screen is still shown in progress after coming back.
  final Map<int, DownloadProgress> bookDownloads;

  final int? previewingBookId;

  /// Previews are screen local — leaving the screen abandons the wait.
  final DownloadProgress previewProgress;

  final Set<int> downloadedBookIds;
  final String? errorKey;
  final String? messageKey;

  bool get isFirstLoad =>
      status != SubjectContentStatus.failure && content == null;

  bool get hasFailed =>
      status == SubjectContentStatus.failure && content == null;

  SubjectContentModel? get subject => content;

  List<TextbookModel> get books =>
      content?.textbooks ?? const <TextbookModel>[];

  Set<int> get downloadingBookIds => bookDownloads.keys.toSet();

  bool isDownloadingBook(int bookId) => bookDownloads.containsKey(bookId);

  bool isPreviewingBook(int bookId) => previewingBookId == bookId;

  bool isBookBusy(int bookId) =>
      isDownloadingBook(bookId) || isPreviewingBook(bookId);

  bool isBookDownloaded(int bookId) => downloadedBookIds.contains(bookId);

  /// Progress for [bookId] only while it is the busy one, else null.
  DownloadProgress? progressFor(int bookId) {
    final DownloadProgress? download = bookDownloads[bookId];
    if (download != null) return download;

    return isPreviewingBook(bookId) ? previewProgress : null;
  }

  SubjectContentState copyWith({
    SubjectContentStatus? status,
    LessonCategory? selectedCategory,
    SubjectContentModel? content,
    List<LessonModel>? lessons,
    List<LiveSessionModel>? liveSessions,
    List<MediaAlbumModel>? albums,
    Map<int, DownloadProgress>? bookDownloads,
    int? previewingBookId,
    DownloadProgress? previewProgress,
    Set<int>? downloadedBookIds,
    String? errorKey,
    String? messageKey,
    bool clearError = false,
    bool clearPreviewingBook = false,
    bool resetPreviewProgress = false,
  }) => SubjectContentState(
    status: status ?? this.status,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    content: content ?? this.content,
    lessons: lessons ?? this.lessons,
    liveSessions: liveSessions ?? this.liveSessions,
    albums: albums ?? this.albums,
    bookDownloads: bookDownloads ?? this.bookDownloads,
    previewingBookId: clearPreviewingBook
        ? null
        : previewingBookId ?? this.previewingBookId,
    previewProgress: resetPreviewProgress
        ? DownloadProgress.none
        : previewProgress ?? this.previewProgress,
    downloadedBookIds: downloadedBookIds ?? this.downloadedBookIds,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    messageKey: messageKey,
  );
}
