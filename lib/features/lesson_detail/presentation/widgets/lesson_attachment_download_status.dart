import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
        Icon(icon, size: (16).r(context), color: color),

        SizedBox(width: (6).w(context)),

        Expanded(
          child: Text(
            labelKey.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).cardCaption.copyWith(color: color),
          ),
        ),

        SizedBox(width: (6).w(context)),

        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular((6).r(context)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: (6).w(context), vertical: (2).h(context)),
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
