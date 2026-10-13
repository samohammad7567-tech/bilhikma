import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/file_download_state.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import 'lesson_attachment_download_status.dart';

class LessonAttachmentDownloadBar extends StatelessWidget {
  const LessonAttachmentDownloadBar({
    required this.download,
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });

  final FileDownloadState download;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (download.isCompleted) {
      return LessonAttachmentDownloadStatus(
        icon: Icons.check_circle_outline,
        labelKey: 'attachment_download_complete',
        color: Theme.of(context).colorScheme.secondaryContainer,
        actionKey: 'dismiss',
        onAction: onDismiss,
      );
    }

    if (download.isFailed) {
      return LessonAttachmentDownloadStatus(
        icon: Icons.error_outline,
        labelKey: download.errorKey ?? 'attachment_download_failed',
        color: Theme.of(context).colorScheme.error,
        actionKey: 'retry',
        onAction: onRetry,
      );
    }

    return _running(context);
  }

  Widget _running(BuildContext context) {
    final double? fraction = download.progress.fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'downloading_attachment'.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).cardCaption,
              ),
            ),

            SizedBox(width: 8.w),

            Text(
              download.progress.readableRatio,
              textAlign: TextAlign.end,
              maxLines: 1,
              style: AppTheme.styles(context).cardCaption,
            ),
          ],
        ),

        SizedBox(height: 4.h),

        if (fraction != null)
          AppProgressBar(progress: fraction, height: 4.h, showPercent: false)
        else
          _indeterminate(context),
      ],
    );
  }

  Widget _indeterminate(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double height = 4.h;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        minHeight: height,
        backgroundColor: colors.surfaceContainerLowest,
        valueColor: AlwaysStoppedAnimation<Color>(colors.secondaryContainer),
      ),
    );
  }
}
