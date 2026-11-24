import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestTimerChip extends StatelessWidget {
  const TestTimerChip({
    required this.label,
    super.key,
    this.icon = Icons.timer_outlined,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle style = AppTheme.styles(context).labelSmall;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (4).h(context)),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? colors.primaryContainer.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular((20).r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: (13).r(context), color: color ?? colors.onSurfaceVariant),

          SizedBox(width: (5).w(context)),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: color == null ? style : style.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
