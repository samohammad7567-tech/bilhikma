import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'stat_tile.dart';
import 'home_progress_tile.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    required this.overallProgress,
    required this.lessonsCount,
    required this.subjectsCount,
    super.key,
  });

  final double overallProgress;
  final int lessonsCount;
  final int subjectsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all((8).r(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StatTile(
                value: '$subjectsCount',
                label: 'study_subjects'.tr(),
              ),
            ),

            SizedBox(width: (8).w(context)),

            Expanded(
              child: StatTile(value: '$lessonsCount', label: 'lessons'.tr()),
            ),

            SizedBox(width: (8).w(context)),

            Expanded(
              flex: 3,
              child: HomeProgressTile(progress: overallProgress),
            ),
          ],
        ),
      ),
    );
  }
}
