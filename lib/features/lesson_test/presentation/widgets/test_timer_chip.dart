import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class TestTimerChip extends StatelessWidget {
  const TestTimerChip({
    required this.label,
    super.key,
    this.icon = Icons.timer_outlined,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13.w, color: colors.onSurfaceVariant),

          SizedBox(width: 5.w),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelSmall,
          ),
        ],
      ),
    );
  }
}
