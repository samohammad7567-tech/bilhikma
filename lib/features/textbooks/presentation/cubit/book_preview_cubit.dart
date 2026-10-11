import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/enums/book_page_layout_enum.dart';
import '../../../../core/routing/book_preview_args.dart';
import '../../data/models/reading_position.dart';
import '../../data/repos/pdf_reader_repo.dart';

part 'book_preview_state.dart';

class BookPreviewCubit extends Cubit<BookPreviewState> {
  /// The saved position is read synchronously here so the viewer can be built
  /// already pointing at the right page — jumping after load would show the
  /// first page, then scroll, on every open.
  BookPreviewCubit({
    required BookPreviewArgs args,
    PdfReaderRepo repo = const PdfReaderRepo(),
  }) : this._(args, repo, repo.positionFor(args.readingKey), repo.layout);

  BookPreviewCubit._(
    this.args,
    this.repo,
    ReadingPosition? saved,
    BookPageLayout layout,
  ) : resume = saved ?? ReadingPosition.start,
      super(BookPreviewState(page: saved?.page ?? 1, layout: layout));

  final BookPreviewArgs args;
  final PdfReaderRepo repo;

  /// Where the document was left, for the viewer's initial page and zoom.
  final ReadingPosition resume;

  final PdfViewerController controller = PdfViewerController();

  /// The viewer's own outline panel is reached through its state, not the
  /// controller — this is the handle to it.
  final GlobalKey<SfPdfViewerState> viewerKey = GlobalKey<SfPdfViewerState>();

  /// Page turns are frequent and each save writes preferences, so the write
  /// trails the reader rather than following every turn.
  static const Duration _saveDelay = Duration(milliseconds: 1200);

  Timer? _saveTimer;
  PdfTextSearchResult? _search;

  /// The saved page is honoured once, so a document reloaded for any reason
  /// stays on the page being read.
  bool _hasRestored = false;

  @override
  Future<void> close() {
    _flushPosition();
    _search?.removeListener(_onSearchChanged);
    return super.close();
  }

  void onDocumentLoaded(PdfDocumentLoadedDetails details) {
    if (isClosed) return;

    final int pageCount = details.document.pages.count;

    final bool isFirstLoad = !_hasRestored;
    _hasRestored = true;

    final int target = isFirstLoad
        ? resume.pageWithin(pageCount)
        : state.page.clamp(1, pageCount < 1 ? 1 : pageCount);

    emit(
      state.copyWith(
        isLoaded: true,
        pageCount: pageCount,
        page: target,
        isResumed: isFirstLoad && target > 1,
        hasOutline: _outlineCount(details) > 0,
        clearError: true,
      ),
    );

    _settleOnPage(target);
  }

  /// `initialPageNumber` is ignored by the viewer when it falls outside the
  /// document, which happens when a book is replaced by a shorter edition.
  /// The jump is deferred so it does not race the viewer's own initial one.
  void _settleOnPage(int target) {
    if (controller.pageNumber == target) return;

    Future<void>.microtask(() {
      if (isClosed || controller.pageNumber == target) return;

      controller.jumpToPage(target);
    });
  }

  void onDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    if (isClosed) return;

    emit(state.copyWith(errorKey: 'reader_load_failed'));
  }

  void onPageChanged(PdfPageChangedDetails details) {
    if (isClosed) return;

    emit(state.copyWith(page: details.newPageNumber));
    _scheduleSave();
  }

  /// Live value while the scrubber is dragged — the document is only moved on
  /// release, since rendering every page dragged past is what makes a long
  /// book crawl.
  void scrubTo(double value) {
    if (!state.hasPages) return;

    emit(state.copyWith(scrubPage: value.round().clamp(1, state.pageCount)));
  }

  void commitScrub() {
    final int? target = state.scrubPage;
    emit(state.copyWith(clearScrubPage: true));

    if (target == null) return;
    goToPage(target);
  }

  void goToPage(int page) {
    if (!state.isLoaded) return;

    final int target = page.clamp(1, state.pageCount);
    controller.jumpToPage(target);
  }

  void nextPage() => controller.nextPage();

  void previousPage() => controller.previousPage();

  Future<void> toggleLayout() async {
    final BookPageLayout next = state.layout.toggled;

    emit(state.copyWith(layout: next));
    await repo.saveLayout(next);
  }

  void openOutline() {
    if (!state.hasOutline) return;

    viewerKey.currentState?.openBookmarkView();
  }

  void openSearch() => emit(state.copyWith(isSearchOpen: true));

  void closeSearch() {
    _clearSearch();

    emit(
      state.copyWith(
        isSearchOpen: false,
        query: '',
        isSearching: false,
        matchCount: 0,
        matchIndex: 0,
      ),
    );
  }

  void search(String query) {
    final String trimmed = query.trim();
    if (!state.isLoaded) return;

    _clearSearch();

    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          isSearching: false,
          matchCount: 0,
          matchIndex: 0,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        query: trimmed,
        isSearching: true,
        matchCount: 0,
        matchIndex: 0,
      ),
    );

    _search = controller.searchText(trimmed)..addListener(_onSearchChanged);
  }

  void nextMatch() => _search?.nextInstance();

  void previousMatch() => _search?.previousInstance();

  void _onSearchChanged() {
    final PdfTextSearchResult? result = _search;
    if (isClosed || result == null) return;

    emit(
      state.copyWith(
        isSearching: !result.isSearchCompleted,
        matchCount: result.totalInstanceCount,
        matchIndex: result.currentInstanceIndex,
      ),
    );
  }

  void _clearSearch() {
    _search?.removeListener(_onSearchChanged);
    _search?.clear();
    _search = null;
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, _flushPosition);
  }

  void _flushPosition() {
    _saveTimer?.cancel();
    _saveTimer = null;

    if (!state.isLoaded) return;

    unawaited(
      repo.savePosition(
        args.readingKey,
        ReadingPosition(
          page: state.page,
          pageCount: state.pageCount,
          zoom: controller.zoomLevel,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  /// A malformed outline tree is common in scanned books, and reading it must
  /// not take the viewer down — it only decides whether a button is shown.
  int _outlineCount(PdfDocumentLoadedDetails details) {
    try {
      return details.document.bookmarks.count;
    } catch (_) {
      return 0;
    }
  }
}
