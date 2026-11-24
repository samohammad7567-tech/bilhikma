import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class VideoCircleIconButton extends StatelessWidget {
  const VideoCircleIconButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all((8).r(context)),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: (20).r(context)),
      ),
    );
  }
}
