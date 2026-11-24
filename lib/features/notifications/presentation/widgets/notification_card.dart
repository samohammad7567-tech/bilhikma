import 'package:flutter/material.dart';

import '../../../../core/themes/notification_tone_palette.dart';
import '../../data/models/notification_model.dart';
import 'notification_kind_tile.dart';
import 'notification_card_text.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    super.key,
    this.onTap,
    this.isOpening = false,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final bool isOpening;
  static const double _barWidth = 4;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final NotificationTonePalette tone = NotificationTonePalette.of(
      context,
      notification.kind.tone,
    );

    final bool isUnread = !notification.isRead;
    final Color background = isUnread
        ? tone.background
        : tone.readBackground(colors);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular((12).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: _barWidth,
                color: isUnread
                    ? tone.accent
                    : tone.accent.withValues(alpha: 0.55),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB((10).w(context), (10).h(context), (12).w(context), (10).h(context)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _leading(context, tone),

                      SizedBox(width: (10).w(context)),

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

  Widget _leading(BuildContext context, NotificationTonePalette tone) {
    if (!isOpening) {
      return NotificationKindTile(kind: notification.kind, tone: tone);
    }

    return SizedBox.square(
      dimension: NotificationKindTile.size,
      child: Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: (2).r(context),
            valueColor: AlwaysStoppedAnimation<Color>(tone.accent),
          ),
        ),
      ),
    );
  }
}
