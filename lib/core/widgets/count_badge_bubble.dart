import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountBadgeBubble extends StatelessWidget {
  const CountBadgeBubble({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.surfaceContainerLowest, width: 1.5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onError,
          fontSize: 10.sp,
          height: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
