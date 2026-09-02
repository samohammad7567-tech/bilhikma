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
    this.downloadingBookId,
    this.previewingBookId,
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

  final int? downloadingBookId;

  final int? previewingBookId;

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

  bool isDownloadingBook(int bookId) => downloadingBookId == bookId;

  bool isPreviewingBook(int bookId) => previewingBookId == bookId;

  bool isBookBusy(int bookId) =>
      isDownloadingBook(bookId) || isPreviewingBook(bookId);

  bool isBookDownloaded(int bookId) => downloadedBookIds.contains(bookId);

  SubjectContentState copyWith({
    SubjectContentStatus? status,
    LessonCategory? selectedCategory,
    SubjectContentModel? content,
    List<LessonModel>? lessons,
    List<LiveSessionModel>? liveSessions,
    List<MediaAlbumModel>? albums,
    int? downloadingBookId,
    int? previewingBookId,
    Set<int>? downloadedBookIds,
    String? errorKey,
    String? messageKey,
    bool clearError = false,
    bool clearDownloadingBook = false,
    bool clearPreviewingBook = false,
  }) => SubjectContentState(
    status: status ?? this.status,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    content: content ?? this.content,
    lessons: lessons ?? this.lessons,
    liveSessions: liveSessions ?? this.liveSessions,
    albums: albums ?? this.albums,
    downloadingBookId: clearDownloadingBook
        ? null
        : downloadingBookId ?? this.downloadingBookId,
    previewingBookId: clearPreviewingBook
        ? null
        : previewingBookId ?? this.previewingBookId,
    downloadedBookIds: downloadedBookIds ?? this.downloadedBookIds,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    messageKey: messageKey,
  );
}
