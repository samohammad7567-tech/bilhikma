import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../data/models/notification_model.dart';
import '../refactor/notification_formats.dart';
import 'notification_kind_chip.dart';
import 'notification_kind_tile.dart';

/// The whole notification, for the ones that refer to no screen.
///
/// An announcement is only ever its own text and picture, and the card clamps
/// the message to two lines — without this there is nowhere to read the rest.
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
          _image(context),
          SizedBox(height: 12.h),
        ],

        // Not clamped: the message is the reason this sheet exists, and some
        // announcements are a numbered list several lines long.
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

  Widget _image(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: AppNetworkImage(
      url: notification.imageUrl!,
      height: 170.h,
      fit: BoxFit.cover,
      errorWidget: const SizedBox.shrink(),
      placeholder: SizedBox(
        height: 170.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
    ),
  );
}
