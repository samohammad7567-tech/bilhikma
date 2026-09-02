import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCircleAvatar extends StatelessWidget {
  const AppCircleAvatar({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? 50.w;

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.09),
        shape: BoxShape.circle,
      ),

      child: Icon(
        Icons.person,
        size: diameter * 0.55,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
