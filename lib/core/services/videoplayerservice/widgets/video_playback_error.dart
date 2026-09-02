import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../video_player_options.dart';
import 'video_circle_icon_button.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: options.foregroundColor,
              size: 32,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: options.foregroundColor, fontSize: 14),
            ),

            const SizedBox(height: 16),

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

                const SizedBox(width: 8),

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
