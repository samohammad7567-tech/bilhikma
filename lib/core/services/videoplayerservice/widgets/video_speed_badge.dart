import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoSpeedBadge extends StatelessWidget {
  const VideoSpeedBadge({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(CupertinoIcons.forward_fill, color: color, size: 18),

          const SizedBox(width: 4),

          const Text(
            '2x',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
