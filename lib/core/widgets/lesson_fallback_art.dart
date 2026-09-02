import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_assets.dart';

class LessonFallbackArt extends StatelessWidget {
  const LessonFallbackArt({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(10.w),
    child: Image.asset(AppAssets.assetsBookIcon, fit: BoxFit.contain),
  );
}
