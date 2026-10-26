import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A spinner scoped to its own box, for an action the user just triggered.
///
/// Belongs inside a button or a row. A screen's first-load state is a skeleton
/// instead, never this.
class AppInlineLoader extends StatelessWidget {
  const AppInlineLoader({super.key, this.size, this.strokeWidth, this.color});

  final double? size;
  final double? strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? 20.w;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 2.2,
        color: color ?? Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
