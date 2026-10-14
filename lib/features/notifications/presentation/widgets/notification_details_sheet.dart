import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../data/models/notification_model.dart';
import '../refactor/notification_formats.dart';
import 'notification_image.dart';
import 'notification_kind_chip.dart';
import 'notification_kind_tile.dart';

class NotificationDetailsSheet extends StatelessWidget {
  const NotificationDetailsSheet({required this.notification, super.key});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);

    final NotificationTonePalette tone = NotificationTonePalette.of(
      context,
      notification.kind.tone,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SheetHandle(),

        SizedBox(height: 14.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NotificationKindTile(kind: notification.kind, tone: tone),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  NotificationKindChip(kind: notification.kind),

                  SizedBox(height: 6.h),

                  Text(
                    notification.title,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: styles.cardTitle,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        if (notification.hasImage) ...<Widget>[
          _image(),
          SizedBox(height: 12.h),
        ],
        Text(
          notification.message,
          textAlign: TextAlign.start,
          style: styles.cardSubtitle,
        ),

        SizedBox(height: 14.h),

        Text(
          NotificationFormats.stamp(notification.sentAt),
          textAlign: TextAlign.start,
          maxLines: 1,
          style: styles.cardCaption,
        ),

        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _image() => NotificationImage(
    url: notification.imageUrl!,
    heroTag: 'notification-image-${notification.id}',
  );
}
