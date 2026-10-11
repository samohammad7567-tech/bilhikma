import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../refactor/notification_formats.dart';
import 'notification_kind_chip.dart';

class NotificationCardText extends StatelessWidget {
  const NotificationCardText({
    required this.notification,
    required this.tone,
    super.key,
  });

  final NotificationModel notification;
  final NotificationTonePalette tone;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                notification.title,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.cardTitle.copyWith(color: tone.title),
              ),
            ),

            SizedBox(width: 8.w),

            NotificationKindChip(kind: notification.kind),
          ],
        ),

        SizedBox(height: 4.h),

        Text(
          notification.message,
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.cardSubtitle.copyWith(color: tone.body),
        ),

        SizedBox(height: 6.h),

        Text(
          _stamp(),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.cardCaption.copyWith(
            color: tone.body.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  /// `اليوم ١٠:٣٠ ص • جديد` — when it arrived, and whether it is still new.
  String _stamp() {
    final String when = NotificationFormats.stamp(notification.sentAt);
    final String state = notification.isRead
        ? 'notification_state_read'.tr()
        : 'notification_state_new'.tr();

    return '$when • $state';
  }
}
