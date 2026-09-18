import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import '../refactor/lesson_progress_view.dart';

class LessonSummaryPosition extends StatelessWidget {
  const LessonSummaryPosition({required this.view, super.key});

  final LessonProgressView view;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double barHeight = 6.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: <Widget>[
              Text(
                LessonDetailFormats.position(
                  totalSeconds: view.totalSeconds,
                  elapsedSeconds: view.elapsedSeconds,
                ),
                maxLines: 1,
                style: AppTheme.styles(context).progressLabel,
              ),

              const Spacer(),

              Text(
                '${view.percent}%',
                maxLines: 1,
                style: AppTheme.styles(context).progressLabel,
              ),
            ],
          ),
        ),

        SizedBox(height: 6.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight),
          child: Stack(
            children: <Widget>[
              if (view.hasPending)
                LinearProgressIndicator(
                  value: view.pending,
                  minHeight: barHeight,
                  backgroundColor: colors.surfaceContainerLowest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.secondaryContainer.withValues(alpha: 0.4),
                  ),
                ),

              LinearProgressIndicator(
                value: view.confirmed,
                minHeight: barHeight,
                backgroundColor: view.hasPending
                    ? Colors.transparent
                    : colors.surfaceContainerLowest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.secondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
