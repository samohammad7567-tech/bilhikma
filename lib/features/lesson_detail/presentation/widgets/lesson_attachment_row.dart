import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/lesson_attachment_model.dart';
import '../../../../core/themes/app_theme.dart';
import 'lesson_attachment_thumbnail.dart';
import 'lesson_attachment_action.dart';

class LessonAttachmentRow extends StatelessWidget {
  const LessonAttachmentRow({
    required this.file,
    required this.onDownload,
    required this.onPreview,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.isDownloaded = false,
    super.key,
  });

  final LessonAttachmentModel file;
  final VoidCallback onDownload;
  final VoidCallback onPreview;
  final bool isDownloading;
  final bool isPreviewing;

  final bool isDownloaded;

  static const double _actionsWidth = 140;

  @override
  Widget build(BuildContext context) {
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
    final Widget preview = LessonAttachmentAction(
      labelKey: 'preview',
      icon: Icons.visibility_outlined,
      isFilled: isDownloaded,
      isExpanded: true,
      onPressed: onPreview,
      isBusy: isPreviewing,
    );

    if (isDownloaded) return preview;

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

        Expanded(child: preview),
      ],
    );
  }
}
