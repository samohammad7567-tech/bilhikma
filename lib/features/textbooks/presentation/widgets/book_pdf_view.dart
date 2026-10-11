import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/enums/book_page_layout_enum.dart';
import '../../data/models/reading_position.dart';
import '../cubit/book_preview_cubit.dart';

/// The viewer itself, tuned for long documents.
class BookPdfView extends StatelessWidget {
  const BookPdfView({
    required this.cubit,
    required this.filePath,
    required this.layout,
    required this.initialPage,
    super.key,
  });

  final BookPreviewCubit cubit;
  final String filePath;
  final BookPageLayout layout;

  /// The saved page on the first build, and the page being read when a layout
  /// change rebuilds the viewer.
  final int initialPage;

  @override
  Widget build(BuildContext context) {
    final bool isSingle = layout.isSingle;

    return SfPdfViewer.file(
      File(filePath),
      // The viewer reconfigures itself when the layout changes and keeps the
      // reading position, so this must not be rebuilt from scratch.
      key: cubit.viewerKey,
      controller: cubit.controller,
      onDocumentLoaded: cubit.onDocumentLoaded,
      onDocumentLoadFailed: cubit.onDocumentLoadFailed,
      onPageChanged: cubit.onPageChanged,

      pageLayoutMode: isSingle
          ? PdfPageLayoutMode.single
          : PdfPageLayoutMode.continuous,

      // Opening straight at the page, rather than jumping after load, is why
      // a resume does not flash the first page.
      initialPageNumber: initialPage,
      initialZoomLevel: cubit.resume.zoom,
      maxZoomLevel: ReadingPosition.maxZoom,

      pageSpacing: isSingle ? 0 : 4,

      // The reader bar below owns navigation, so the built in scroll head,
      // status overlay and pagination dialog would only duplicate it.
      canShowScrollHead: false,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,

      // These books are watermarked and the app blocks screen capture, so
      // there is nothing to gain from a copy menu — and dropping the text
      // layer takes work off every page turn.
      enableTextSelection: false,
      canShowTextSelectionMenu: false,
      interactionMode: PdfInteractionMode.pan,
    );
  }
}
