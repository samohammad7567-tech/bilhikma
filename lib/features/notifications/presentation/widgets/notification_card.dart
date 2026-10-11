import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../data/models/notification_model.dart';
import 'notification_kind_tile.dart';
import 'notification_card_text.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    super.key,
    this.onTap,
    this.isOpening = false,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  /// A live session is fetched before its screen can open.
  final bool isOpening;

  /// Width of the accent bar down the leading edge.
  static const double _barWidth = 4;

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
        child: IntrinsicHeight(
          child: Row(
            // Stretch so the accent bar runs the full height of the card.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: _barWidth.w,
                color: isUnread
                    ? tone.accent
                    : tone.accent.withValues(alpha: 0.55),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 12.w, 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _leading(tone),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: NotificationCardText(
                          notification: notification,
                          tone: tone,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading(NotificationTonePalette tone) {
    if (!isOpening) {
      return NotificationKindTile(kind: notification.kind, tone: tone);
    }

    return SizedBox.square(
      dimension: NotificationKindTile.size.w,
      child: Center(
        child: SizedBox.square(
          dimension: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(tone.accent),
          ),
        ),
      ),
    );
  }
}
