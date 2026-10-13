import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/widgets/ornamented_card.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/widgets/lesson_thumbnail.dart';
import '../../../../core/models/textbook_model.dart';
import 'subject_book_actions.dart';
import 'subject_book_details.dart';

class SubjectBookCard extends StatelessWidget {
  const SubjectBookCard({
    required this.book,
    required this.onDownload,
    required this.onPreview,
    required this.onOpen,
    super.key,
    this.progress,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.isDownloaded = false,
  });

  final TextbookModel book;
  final VoidCallback onDownload;
  final VoidCallback onPreview;
  final VoidCallback onOpen;

  final DownloadProgress? progress;

  final bool isDownloading;
  final bool isPreviewing;

  final bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      radius: 14.r,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const LessonThumbnail(mediaType: ContentType.article),

                SizedBox(width: 12.w),

                Expanded(child: SubjectBookDetails(book: book)),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          SubjectBookActions(
            progress: progress,
            isDownloading: isDownloading,
            isPreviewing: isPreviewing,
            isDownloaded: isDownloaded,
            onDownload: onDownload,
            onPreview: onPreview,
            onOpen: onOpen,
          ),
        ],
      ),
    );
  }
}
