import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.progress,
    super.key,
    this.height,
    this.showPercent = true,
  });
  final double progress;

  final double? height;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double barHeight = height ?? 6.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showPercent) ...<Widget>[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${(progress * 100).round()}%',
              maxLines: 1,
              style: AppTheme.styles(context).progressLabel,
            ),
          ),

          SizedBox(height: 4.h),
        ],

        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: barHeight,
            backgroundColor: colors.surfaceContainerLowest,
            valueColor: AlwaysStoppedAnimation<Color>(
              colors.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
