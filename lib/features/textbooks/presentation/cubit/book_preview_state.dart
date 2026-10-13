part of 'book_preview_cubit.dart';

final class BookPreviewState {
  const BookPreviewState({
    this.page = 1,
    this.pageCount = 0,
    this.layout = BookPageLayout.single,
    this.isLoaded = false,
    this.isResumed = false,
    this.hasOutline = false,
    this.scrubPage,
    this.isSearchOpen = false,
    this.query = '',
    this.isSearching = false,
    this.matchCount = 0,
    this.matchIndex = 0,
    this.errorKey,
  });

  final int page;
  final int pageCount;

  final BookPageLayout layout;

  final bool isLoaded;
  final bool isResumed;

  final bool hasOutline;
  final int? scrubPage;

  final bool isSearchOpen;
  final String query;
  final bool isSearching;
  final int matchCount;
  final int matchIndex;

  final String? errorKey;

  bool get hasPages => pageCount > 0;

  bool get hasFailed => errorKey != null;
  int get shownPage => scrubPage ?? page;

  double get sliderValue =>
      shownPage.clamp(1, pageCount == 0 ? 1 : pageCount).toDouble();

  double get sliderMax => pageCount <= 1 ? 1 : pageCount.toDouble();

  bool get canGoBack => isLoaded && page > 1;

  bool get canGoForward => isLoaded && hasPages && page < pageCount;

  bool get hasQuery => query.isNotEmpty;

  bool get hasMatches => matchCount > 0;
  bool get hasNoMatches => hasQuery && !isSearching && matchCount == 0;

  BookPreviewState copyWith({
    int? page,
    int? pageCount,
    BookPageLayout? layout,
    bool? isLoaded,
    bool? isResumed,
    bool? hasOutline,
    int? scrubPage,
    bool? isSearchOpen,
    String? query,
    bool? isSearching,
    int? matchCount,
    int? matchIndex,
    String? errorKey,
    bool clearError = false,
    bool clearScrubPage = false,
  }) => BookPreviewState(
    page: page ?? this.page,
    pageCount: pageCount ?? this.pageCount,
    layout: layout ?? this.layout,
    isLoaded: isLoaded ?? this.isLoaded,
    isResumed: isResumed ?? this.isResumed,
    hasOutline: hasOutline ?? this.hasOutline,
    scrubPage: clearScrubPage ? null : scrubPage ?? this.scrubPage,
    isSearchOpen: isSearchOpen ?? this.isSearchOpen,
    query: query ?? this.query,
    isSearching: isSearching ?? this.isSearching,
    matchCount: matchCount ?? this.matchCount,
    matchIndex: matchIndex ?? this.matchIndex,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
