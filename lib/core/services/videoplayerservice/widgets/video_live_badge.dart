import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class VideoLiveBadge extends StatelessWidget {
  const VideoLiveBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (5).h(context)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular((6).r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: (7).w(context),
            height: (7).h(context),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: (6).w(context)),

          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: (12).sp(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
