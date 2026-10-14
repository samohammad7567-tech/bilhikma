import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';

class BookDownloadProgress extends StatelessWidget {
  const BookDownloadProgress({
    required this.progress,
    required this.labelKey,
    super.key,
    this.onCancel,
    this.isCancelling = false,
  });

  final DownloadProgress progress;
  final String labelKey;

  /// Stops the transfer. Left null for work that cannot be called off, such
  /// as preparing a book for preview.
  final VoidCallback? onCancel;

  /// A stop has been asked for and the transfer is winding down.
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final double? fraction = progress.fraction;
    final String ratio = progress.readableRatio;
    final bool showRatio = progress.hasStarted && ratio.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                isCancelling ? 'cancelling_download'.tr() : labelKey.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),
            ),

            if (showRatio && !isCancelling) ...<Widget>[
              SizedBox(width: 8.w),

              Text(
                ratio,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: AppTheme.styles(context).cardCaption,
              ),
            ],

            if (onCancel != null) ...<Widget>[
              SizedBox(width: 4.w),

              _cancelButton(context),
            ],
          ],
        ),

        SizedBox(height: 6.h),

        if (fraction != null)
          AppProgressBar(progress: fraction, height: 6.h)
        else
          _indeterminate(context),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'cancel_download'.tr(),
      child: InkWell(
        onTap: isCancelling ? null : onCancel,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Icon(
            Icons.close_rounded,
            size: 18.w,
            color: isCancelling
                ? colors.onSurfaceVariant.withValues(alpha: 0.5)
                : colors.error,
          ),
        ),
      ),
    );
  }

  Widget _indeterminate(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double height = 6.h;

    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          minHeight: height,
          backgroundColor: colors.surfaceContainerLowest,
          valueColor: AlwaysStoppedAnimation<Color>(colors.secondaryContainer),
        ),
      ),
    );
  }
}
