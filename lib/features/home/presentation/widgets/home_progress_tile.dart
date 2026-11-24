import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../refactor/home_formats.dart';
import 'progress_ring.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class HomeProgressTile extends StatelessWidget {
  const HomeProgressTile({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (8).h(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular((10).r(context)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  HomeFormats.overallProgress(progress),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).labelStrong,
                ),

                SizedBox(height: (2).h(context)),

                Text(
                  'keep_going'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).statLabel,
                ),
              ],
            ),
          ),

          SizedBox(width: (8).w(context)),

          ProgressRing(progress: progress),
        ],
      ),
    );
  }
}
