import 'package:flutter/cupertino.dart';
import '../video_item.dart';
import '../video_player_options.dart';

class VideoDetails extends StatelessWidget {
  const VideoDetails({required this.item, required this.options, super.key});

  final VideoItem item;
  final FloatingVideoOptions options;

  @override
  Widget build(BuildContext context) {
    final String title = item.title?.trim() ?? '';
    final String subtitle = item.subtitle?.trim() ?? '';
    final String date = item.date?.trim() ?? '';
    final String description = item.description?.trim() ?? '';

    final Color fg = options.foregroundColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              color: fg,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

        if (subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 16),
          ),
        ],

        if (date.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: fg.withValues(alpha: 0.5),
              ),

              const SizedBox(width: 6),

              Text(
                date,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],

        if (description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),

          Text(
            options.descriptionLabel,
            style: TextStyle(
              color: fg,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: TextStyle(
              color: fg.withValues(alpha: 0.8),
              fontSize: 17,
              height: 1.7,
            ),
          ),
        ],
      ],
    );
  }
}
