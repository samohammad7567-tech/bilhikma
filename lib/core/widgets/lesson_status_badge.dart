import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../utils/lesson_view_data.dart';
import '../enums/lesson_status_enum.dart';
import '../themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonStatusBadge extends StatelessWidget {
  const LessonStatusBadge({required this.status, super.key});

  final LessonStatus status;

  @override
  Widget build(BuildContext context) {
    final String? label = status.badgeLabel;
    if (label == null) return const SizedBox.shrink();

    final ({Color background, Color foreground}) badge = status.badgeColors(
      Theme.of(context).colorScheme,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (4).h(context)),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular((6).r(context)),
      ),
      child: Text(
        label.tr(),
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).badgeLabel.copyWith(color: badge.foreground),
      ),
    );
  }
}
