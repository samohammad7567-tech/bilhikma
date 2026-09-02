import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../data/models/notification_model.dart';
import 'notification_kind_tile.dart';
import 'notification_time_chip.dart';
import 'notification_unread_dot.dart';
import 'notification_card_text.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({required this.notification, super.key, this.onTap});

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;

    return Material(
      color: isUnread ? AppColors.sand : AppColors.sandSoft,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: <Widget>[
              NotificationKindTile(kind: notification.kind),

              SizedBox(width: 12.w),

              Expanded(child: NotificationCardText(notification: notification)),

              SizedBox(width: 8.w),

              if (isUnread) ...<Widget>[
                const NotificationUnreadDot(),
                SizedBox(width: 8.w),
              ],

              NotificationTimeChip(createdAt: notification.sentAt),
            ],
          ),
        ),
      ),
    );
  }
}
