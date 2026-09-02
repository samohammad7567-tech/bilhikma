import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class TestWordChip extends StatelessWidget {
  const TestWordChip({
    required this.label,
    required this.isUsed,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isUsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isUsed ? 0.45 : 1,
      child: Material(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(8.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isUsed ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).labelStrong,
            ),
          ),
        ),
      ),
    );
  }
}
