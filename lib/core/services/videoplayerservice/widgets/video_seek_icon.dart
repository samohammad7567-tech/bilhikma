import 'package:flutter/material.dart';

class VideoSeekIcon extends StatelessWidget {
  const VideoSeekIcon({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
