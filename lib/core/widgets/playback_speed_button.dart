import 'package:flutter/material.dart';

import '../enums/playback_speed_enum.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({
    required this.speed,
    required this.onTap,
    super.key,
    this.onOverlay = false,
  });

  final PlaybackSpeed speed;

  final VoidCallback onTap;

  final bool onOverlay;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color background = onOverlay
        ? Colors.black.withValues(alpha: 0.45)
        : colors.secondaryContainer.withValues(alpha: 0.15);

    final Color foreground = onOverlay
        ? Colors.white
        : colors.secondaryContainer;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular((20).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (8).w(context), vertical: (4).h(context)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.speed_rounded, size: (14).r(context), color: foreground),

              SizedBox(width: (3).w(context)),

              Text(
                speed.label,
                textDirection: TextDirection.ltr,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
                  fontSize: (11).sp(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
