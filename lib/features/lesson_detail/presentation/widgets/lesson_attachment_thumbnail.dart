import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonAttachmentThumbnail extends StatelessWidget {
  const LessonAttachmentThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular((8).r(context)),
      child: SizedBox(
        width: (44).w(context),
        height: (44).h(context),
        child: Image.asset(AppAssets.assetsLogoOrnament, fit: BoxFit.cover),
      ),
    );
  }
}
