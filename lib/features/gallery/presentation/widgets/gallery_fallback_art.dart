import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class GalleryFallbackArt extends StatelessWidget {
  const GalleryFallbackArt({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all((18).r(context)),
    child: Image.asset(AppAssets.assetsBookIcon, fit: BoxFit.contain),
  );
}
