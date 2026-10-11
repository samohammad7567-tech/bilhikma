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
  });

  final DownloadProgress progress;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final double? fraction = progress.fraction;
    final String ratio = progress.readableRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                labelKey.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),
            ),

            if (ratio.isNotEmpty) ...<Widget>[
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
      ],
    );
  }

  /// Shown until the first byte count arrives, or when the response carries no
  /// length and the API never published a size for the book.
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
