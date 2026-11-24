import 'package:flutter/cupertino.dart';

import '../video_item.dart';
import '../video_player_options.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
              fontSize: (26).sp(context),
              fontWeight: FontWeight.bold,
            ),
          ),

        if (subtitle.isNotEmpty) ...<Widget>[
          SizedBox(height: (6).h(context)),
          Text(
            subtitle,
            style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: (16).sp(context)),
          ),
        ],

        if (date.isNotEmpty) ...<Widget>[
          SizedBox(height: (10).h(context)),
          Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.calendar,
                size: (16).r(context),
                color: fg.withValues(alpha: 0.5),
              ),

              SizedBox(width: (6).w(context)),

              Text(
                date,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.5),
                  fontSize: (14).sp(context),
                ),
              ),
            ],
          ),
        ],

        if (description.isNotEmpty) ...<Widget>[
          SizedBox(height: (20).h(context)),

          Text(
            options.descriptionLabel,
            style: TextStyle(
              color: fg,
              fontSize: (16).sp(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: (8).h(context)),

          Text(
            description,
            style: TextStyle(
              color: fg.withValues(alpha: 0.8),
              fontSize: (17).sp(context),
              height: 1.7.h(context),
            ),
          ),
        ],
      ],
    );
  }
}
