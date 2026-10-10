import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../data/models/notification_model.dart';
import 'notification_kind_tile.dart';
import 'notification_time_chip.dart';
import 'notification_unread_dot.dart';
import 'notification_card_text.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({required this.notification, super.key, this.onTap});

  final NotificationModel notification;
  final VoidCallback? onTap;

  /// Width of the accent bar down the leading edge.
  static const double _barWidth = 5;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final NotificationTonePalette tone = NotificationTonePalette.of(
      context,
      notification.kind.tone,
    );

    final bool isUnread = !notification.isRead;

    // Read cards keep their family colour but settle towards the page, so
    // unread ones still carry the most weight.
    final Color background = isUnread
        ? tone.background
        : tone.readBackground(colors);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isUnread
                  ? tone.border
                  : tone.border.withValues(alpha: 0.45),
              width: isUnread ? 1.4 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              // Stretch so the accent bar runs the full height of the card.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: _barWidth.w,
                  color: isUnread
                      ? tone.accent
                      : tone.accent.withValues(alpha: 0.45),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: <Widget>[
                        NotificationKindTile(
                          kind: notification.kind,
                          tone: tone,
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: NotificationCardText(
                            notification: notification,
                            tone: tone,
                          ),
                        ),

                        SizedBox(width: 8.w),

                        if (isUnread) ...<Widget>[
                          NotificationUnreadDot(color: tone.accent),
                          SizedBox(width: 8.w),
                        ],

                        NotificationTimeChip(
                          createdAt: notification.sentAt,
                          tone: tone,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
