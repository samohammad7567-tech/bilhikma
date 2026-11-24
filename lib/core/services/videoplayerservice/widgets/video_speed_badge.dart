import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class VideoSpeedBadge extends StatelessWidget {
  const VideoSpeedBadge({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: (14).w(context), vertical: (8).h(context)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular((20).r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(CupertinoIcons.forward_fill, color: color, size: (18).r(context)),

          SizedBox(width: (4).w(context)),

          Text(
            '2x',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: (15).sp(context),
            ),
          ),
        ],
      ),
    );
  }
}
