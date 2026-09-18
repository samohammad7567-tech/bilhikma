import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.progress,
    super.key,
    this.pendingProgress,
    this.height,
    this.showPercent = true,
  });

  /// Progress the server has credited.
  final double progress;

  /// Optimistic local progress, drawn behind [progress] in a lighter shade.
  /// Ignored when null or not ahead of [progress].
  final double? pendingProgress;

  final double? height;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double barHeight = height ?? 6.h;

    final double? pending = pendingProgress;
    final bool hasPending = pending != null && pending > progress;
    final double shown = hasPending ? pending : progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showPercent) ...<Widget>[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${(shown * 100).floor()}%',
              maxLines: 1,
              style: AppTheme.styles(context).progressLabel,
            ),
          ),

          SizedBox(height: 4.h),
        ],

        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight),
          child: Stack(
            children: <Widget>[
              if (hasPending)
                LinearProgressIndicator(
                  value: pending,
                  minHeight: barHeight,
                  backgroundColor: colors.surfaceContainerLowest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.secondaryContainer.withValues(alpha: 0.4),
                  ),
                ),

              LinearProgressIndicator(
                value: progress,
                minHeight: barHeight,
                backgroundColor: hasPending
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
