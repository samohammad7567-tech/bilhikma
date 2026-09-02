import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import 'live_session_card_dot.dart';

class LiveSessionCardStatusBadge extends StatelessWidget {
  const LiveSessionCardStatusBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LiveSessionCardDot(),

          SizedBox(width: 6.w),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(
              context,
            ).pillLabel.copyWith(color: colors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
