import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class TestRetryNote extends StatelessWidget {
  const TestRetryNote({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline, size: 18.w, color: colors.onSurfaceVariant),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              'retry_after_days'.tr(
                namedArgs: <String, String>{'days': '$days'},
              ),
              textAlign: TextAlign.center,
              style: AppTheme.styles(context).labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
