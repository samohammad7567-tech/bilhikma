import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class VideoSeekIcon extends StatelessWidget {
  const VideoSeekIcon({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all((12).r(context)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: (28).r(context)),
    );
  }
}
