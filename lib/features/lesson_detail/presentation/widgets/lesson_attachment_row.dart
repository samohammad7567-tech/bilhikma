import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/lesson_attachment_model.dart';
import '../../../../core/models/file_download_state.dart';
import '../../../../core/themes/app_theme.dart';
import 'lesson_attachment_thumbnail.dart';
import 'lesson_attachment_action.dart';
import 'lesson_attachment_download_bar.dart';

class LessonAttachmentRow extends StatelessWidget {
  const LessonAttachmentRow({
    required this.file,
    required this.onDownload,
    required this.onPreview,
    required this.onOpen,
    required this.onRetry,
    required this.onDismissDownload,
    this.download,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.isDownloaded = false,
    super.key,
  });

  final LessonAttachmentModel file;
  final VoidCallback onDownload;
  final VoidCallback onPreview;
  final VoidCallback onOpen;
  final VoidCallback onRetry;
  final VoidCallback onDismissDownload;

  final FileDownloadState? download;
  final bool isDownloading;
  final bool isPreviewing;

  final bool isDownloaded;

  static const double _actionsWidth = 140;

  @override
  Widget build(BuildContext context) {
    final FileDownloadState? active = download;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _details(context),

        if (active != null) ...<Widget>[
          SizedBox(height: 8.h),

          LessonAttachmentDownloadBar(
            download: active,
            onRetry: onRetry,
            onDismiss: onDismissDownload,
          ),
        ],
      ],
    );
  }

  Widget _details(BuildContext context) {
    return Row(
      children: <Widget>[
        const LessonAttachmentThumbnail(),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                file.fileName,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),

              Text(
                file.readableSize,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).cardCaption,
              ),
            ],
          ),
        ),

        SizedBox(width: 8.w),

        SizedBox(width: _actionsWidth.w, child: _actions()),
      ],
    );
  }

  Widget _actions() {
    // A downloaded file is read from disk, so previewing it over the network
    // would only be slower: the single action becomes Open.
    if (isDownloaded) {
      return LessonAttachmentAction(
        labelKey: 'open',
        icon: Icons.folder_open_outlined,
        isFilled: true,
        isExpanded: true,
        onPressed: onOpen,
        isBusy: isPreviewing,
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: LessonAttachmentAction(
            labelKey: 'download',
            icon: Icons.download,
            isFilled: true,
            isExpanded: true,
            onPressed: onDownload,
            isBusy: isDownloading,
          ),
        ),

        SizedBox(width: 6.w),

        Expanded(
          child: LessonAttachmentAction(
            labelKey: 'preview',
            icon: Icons.visibility_outlined,
            isFilled: false,
            isExpanded: true,
            onPressed: onPreview,
            isBusy: isPreviewing,
          ),
        ),
      ],
    );
  }
}
