import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonFallbackArt extends StatelessWidget {
  const LessonFallbackArt({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all((10).r(context)),
    child: Image.asset(AppAssets.assetsBookIcon, fit: BoxFit.contain),
  );
}
