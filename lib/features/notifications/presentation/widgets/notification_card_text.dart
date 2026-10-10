import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/notification_tone_palette.dart';
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
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NotificationKindChip(kind: notification.kind, tone: tone),
        ),

        SizedBox(height: 6.h),

        Text(
          notification.title,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.cardTitle.copyWith(color: tone.title),
        ),

        SizedBox(height: 4.h),

        Text(
          notification.message,
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.cardSubtitle.copyWith(color: tone.body),
        ),
      ],
    );
  }
}
