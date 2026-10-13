import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';

/// The terminal line of an attachment download: downloaded, or failed with a
/// way to try again.
class LessonAttachmentDownloadStatus extends StatelessWidget {
  const LessonAttachmentDownloadStatus({
    required this.icon,
    required this.labelKey,
    required this.color,
    required this.actionKey,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String labelKey;
  final Color color;
  final String actionKey;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16.w, color: color),

        SizedBox(width: 6.w),

        Expanded(
          child: Text(
            labelKey.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).cardCaption.copyWith(color: color),
          ),
        ),

        SizedBox(width: 6.w),

        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(6.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Text(
              actionKey.tr(),
              maxLines: 1,
              style: AppTheme.styles(context).badgeLabel.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
