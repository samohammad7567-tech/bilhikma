import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import 'test_intro_card.dart';

class TestIntroCardRow extends StatelessWidget {
  const TestIntroCardRow({required this.row, super.key});

  final TestIntroRow row;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  row.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).labelSmall,
                ),

                SizedBox(height: 2.h),

                Text(
                  row.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).labelStrong,
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(row.icon, size: 20.w, color: colors.onSecondary),
          ),
        ],
      ),
    );
  }
}
