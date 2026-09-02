import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';

class GalleryFallbackArt extends StatelessWidget {
  const GalleryFallbackArt({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(18.w),
    child: Image.asset(AppAssets.assetsBookIcon, fit: BoxFit.contain),
  );
}
