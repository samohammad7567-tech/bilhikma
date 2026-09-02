import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../security/presentation/widgets/security_watch.dart';

class BookPreviewScreen extends StatelessWidget {
  const BookPreviewScreen({required this.args, super.key});

  final BookPreviewArgs args;

  @override
  Widget build(BuildContext context) {
    return SecurityWatch(
      screen: AppRoutes.bookPreview,
      contentId: args.contentId,
      child: AppSectionScaffold(
        title: args.title,
        child: SfPdfViewer.file(
          File(args.filePath),
          canShowPaginationDialog: false,
          canShowScrollHead: true,
        ),
      ),
    );
  }
}

class BookPreviewArgs {
  const BookPreviewArgs({
    required this.filePath,
    required this.title,
    this.contentId,
  });

  final String filePath;
  final String title;

  final int? contentId;
}
