import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../enums/media_source_enum.dart';
import '../themes/app_theme.dart';
import '../utils/lesson_view_data.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonSourceBadge extends StatelessWidget {
  const LessonSourceBadge({required this.source, super.key});

  final MediaSource source;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) badge = source.badgeColors(
      Theme.of(context).colorScheme,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (4).h(context)),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular((6).r(context)),
      ),
      child: Text(
        source.badgeLabel.tr(),
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).badgeLabel.copyWith(color: badge.foreground),
      ),
    );
  }
}
