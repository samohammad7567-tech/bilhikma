import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';

class LessonAttachmentThumbnail extends StatelessWidget {
  const LessonAttachmentThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Image.asset(AppAssets.assetsLogoOrnament, fit: BoxFit.cover),
      ),
    );
  }
}
