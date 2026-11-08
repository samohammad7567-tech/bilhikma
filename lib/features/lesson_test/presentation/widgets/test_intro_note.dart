import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_html_text.dart';

class TestIntroNote extends StatelessWidget {
  const TestIntroNote({
    required this.icon,
    required this.text,
    super.key,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: (color ?? colors.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18.w, color: color ?? colors.onSurfaceVariant),
          SizedBox(width: 8.w),
          Expanded(
            child: TestHtmlText(
              text,
              style: AppTheme.styles(
                context,
              ).labelMedium.copyWith(color: color ?? colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
