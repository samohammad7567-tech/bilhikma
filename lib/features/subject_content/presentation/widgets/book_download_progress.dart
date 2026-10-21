import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/custom_outline_button.dart';

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
          ],
        ),

        SizedBox(height: 6.h),

        if (fraction != null)
          AppProgressBar(progress: fraction, height: 6.h)
        else
          _indeterminate(context),

        if (onCancel != null) ...<Widget>[
          SizedBox(height: 12.h),

          _cancelButton(context),
        ],
      ],
    );
  }

  /// A full-width, labelled stop — same shape as the Download and Preview
  /// buttons the card shows the rest of the time, so it reads as the action it
  /// is rather than as a decoration on the progress row.
  Widget _cancelButton(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return CustomOutlineButton(
      onPressed: onCancel!,
      text: 'cancel_download'.tr(),
      width: double.infinity,
      height: 46.h,
      threeRadius: 8.r,
      lastRadius: 8.r,
      borderColor: colors.error,
      textColor: colors.error,
      backgroundColor: colors.error.withValues(alpha: 0.06),
      // Winding down: the spinner replaces the label and the button stops
      // taking taps, so a second tap cannot queue a second cancel.
      isLoading: isCancelling,
      loadingWidth: 20.w,
      loadingHeight: 20.w,
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
