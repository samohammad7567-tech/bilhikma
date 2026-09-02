import '../../../../core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';

class ResumeLessonPlayButton extends StatelessWidget {
  const ResumeLessonPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.w,
      height: 54.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: AppIcon(
        asset: AppAssets.assetsStartPalayerIcon,
        width: 17.w,
        height: 19.h,
      ),
    );
  }
}
