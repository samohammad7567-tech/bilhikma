import '../../../../core/widgets/app_icon.dart';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ResumeLessonPlayButton extends StatelessWidget {
  const ResumeLessonPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (54).w(context),
      height: (54).h(context),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
      ),
      child: AppIcon(
        asset: AppAssets.assetsStartPalayerIcon,
        width: (17).w(context),
        height: (19).h(context),
      ),
    );
  }
}
