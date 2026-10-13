import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/enums/book_page_layout_enum.dart';
import '../../data/models/reading_position.dart';
import '../cubit/book_preview_cubit.dart';

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
  final int initialPage;

  @override
  Widget build(BuildContext context) {
    final bool isSingle = layout.isSingle;

    return SfPdfViewer.file(
      File(filePath),
      key: cubit.viewerKey,
      controller: cubit.controller,
      onDocumentLoaded: cubit.onDocumentLoaded,
      onDocumentLoadFailed: cubit.onDocumentLoadFailed,
      onPageChanged: cubit.onPageChanged,

      pageLayoutMode: isSingle
          ? PdfPageLayoutMode.single
          : PdfPageLayoutMode.continuous,
      initialPageNumber: initialPage,
      initialZoomLevel: cubit.resume.zoom,
      maxZoomLevel: ReadingPosition.maxZoom,

      pageSpacing: isSingle ? 0 : 4,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,
      enableTextSelection: false,
      canShowTextSelectionMenu: false,
      interactionMode: PdfInteractionMode.pan,
    );
  }
}
