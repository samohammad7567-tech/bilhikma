import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/file_download_state.dart';
import '../../../../core/widgets/ornamented_card.dart';
import '../../data/models/lesson_attachment_model.dart';
import '../../../../core/themes/app_theme.dart';
import 'lesson_attachment_row.dart';

class LessonAttachmentsCard extends StatelessWidget {
  const LessonAttachmentsCard({
    required this.attachments,
    required this.onDownload,
    required this.onPreview,
    required this.onRetry,
    required this.onDismissDownload,
    this.downloadingId,
    this.previewingId,
    this.downloadedIds = const <int>{},
    this.downloads = const <int, FileDownloadState>{},
    super.key,
  });

  final List<LessonAttachmentModel> attachments;
  final ValueChanged<LessonAttachmentModel> onDownload;
  final ValueChanged<LessonAttachmentModel> onPreview;
  final ValueChanged<LessonAttachmentModel> onRetry;
  final ValueChanged<int> onDismissDownload;

  final Map<int, FileDownloadState> downloads;

  final int? downloadingId;
  final int? previewingId;
  final Set<int> downloadedIds;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      radius: 12.r,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'lesson_attachments'.tr(),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).rowTitle,
          ),

          SizedBox(height: 10.h),

          for (final LessonAttachmentModel file in attachments) ...<Widget>[
            LessonAttachmentRow(
              file: file,
              onDownload: () => onDownload(file),
              onPreview: () => onPreview(file),
              onRetry: () => onRetry(file),
              onDismissDownload: () => onDismissDownload(file.id),
              download: downloads[file.id],
              isDownloading: downloadingId == file.id,
              isPreviewing: previewingId == file.id,
              isDownloaded: downloadedIds.contains(file.id),
            ),
            if (file != attachments.last) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
