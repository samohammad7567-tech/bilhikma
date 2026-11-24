import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../video_player_options.dart';
import 'video_circle_icon_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class VideoPlaybackError extends StatelessWidget {
  const VideoPlaybackError({
    required this.message,
    required this.options,
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  final String message;
  final FloatingVideoOptions options;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.72),
      child: Padding(
        padding: EdgeInsets.all((24).r(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: options.foregroundColor,
              size: (32).r(context),
            ),

            SizedBox(height: (12).h(context)),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: options.foregroundColor, fontSize: (14).sp(context)),
            ),

            SizedBox(height: (16).h(context)),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    options.retryLabel,
                    style: TextStyle(color: options.accentColor),
                  ),
                ),

                SizedBox(width: (8).w(context)),

                VideoCircleIconButton(
                  icon: CupertinoIcons.xmark,
                  onTap: onClose,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
