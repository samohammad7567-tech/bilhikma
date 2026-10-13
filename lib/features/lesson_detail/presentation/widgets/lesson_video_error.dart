import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';

class LessonVideoError extends StatelessWidget {
  const LessonVideoError({required this.onRetry, super.key, this.details});

  final VoidCallback onRetry;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.videocam_off_rounded,
              size: 36.w,
              color: Colors.white.withValues(alpha: 0.75),
            ),

            SizedBox(height: 12.h),

            Text(
              'video_playback_failed'.tr(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: styles.cardCaption.copyWith(color: Colors.white),
            ),

            if (details != null && kDebugMode) ...<Widget>[
              SizedBox(height: 6.h),
              Text(
                details!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: styles.cardCaption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],

            SizedBox(height: 14.h),

            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.w),
              label: Text('retry'.tr()),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
