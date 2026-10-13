import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/enums/book_page_layout_enum.dart';
import '../../../../core/routing/book_preview_args.dart';
import '../../data/models/reading_position.dart';
import '../cubit/book_preview_cubit.dart';

class BookPdfView extends StatelessWidget {
  const BookPdfView({
    required this.cubit,
    required this.args,
    required this.layout,
    required this.initialPage,
    super.key,
  });

  final BookPreviewCubit cubit;
  final BookPreviewArgs args;
  final BookPageLayout layout;
  final int initialPage;

  @override
  Widget build(BuildContext context) {
    // Syncfusion has a separate constructor per source, so the shared reader
    // configuration lives here and both calls below stay identical.
    final bool isSingle = layout.isSingle;
    final PdfPageLayoutMode mode = isSingle
        ? PdfPageLayoutMode.single
        : PdfPageLayoutMode.continuous;
    final double spacing = isSingle ? 0 : 4;

    if (args.isNetwork) {
      return SfPdfViewer.network(
        args.networkUrl,
        key: cubit.viewerKey,
        controller: cubit.controller,
        onDocumentLoaded: cubit.onDocumentLoaded,
        onDocumentLoadFailed: cubit.onDocumentLoadFailed,
        onPageChanged: cubit.onPageChanged,

        pageLayoutMode: mode,
        initialPageNumber: initialPage,
        initialZoomLevel: cubit.resume.zoom,
        maxZoomLevel: ReadingPosition.maxZoom,

        pageSpacing: spacing,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        enableTextSelection: false,
        canShowTextSelectionMenu: false,
        interactionMode: PdfInteractionMode.pan,
      );
    }

    return SfPdfViewer.file(
      File(args.localPath),
      key: cubit.viewerKey,
      controller: cubit.controller,
      onDocumentLoaded: cubit.onDocumentLoaded,
      onDocumentLoadFailed: cubit.onDocumentLoadFailed,
      onPageChanged: cubit.onPageChanged,

      pageLayoutMode: mode,
      initialPageNumber: initialPage,
      initialZoomLevel: cubit.resume.zoom,
      maxZoomLevel: ReadingPosition.maxZoom,

      pageSpacing: spacing,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,
      enableTextSelection: false,
      canShowTextSelectionMenu: false,
      interactionMode: PdfInteractionMode.pan,
    );
  }
}
