import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppInlineLoader extends StatelessWidget {
  const AppInlineLoader({super.key, this.size, this.strokeWidth});

  final double? size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final double loaderSize = size ?? 24.sp;
    final double loaderStroke = strokeWidth ?? 2.sp;

    return SizedBox(
      width: loaderSize,
      height: loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: loaderStroke,
      ),
    );
  }
}
