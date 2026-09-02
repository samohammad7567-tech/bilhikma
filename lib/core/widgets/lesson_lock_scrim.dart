import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_assets.dart';
import '../enums/content_type_enum.dart';
import 'app_icon.dart';

class LessonLockScrim extends StatelessWidget {
  const LessonLockScrim({required this.mediaType, super.key});

  final ContentType mediaType;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: mediaType == ContentType.video
          ? colors.primary.withValues(alpha: 0.55)
          : colors.secondary.withValues(alpha: 0.55),
      child: Center(
        child: AppIcon(
          asset: AppAssets.assetsLockIcon,
          size: 40.w,
          color: mediaType == ContentType.video
              ? colors.onPrimary
              : colors.onSecondary,
        ),
      ),
    );
  }
}
