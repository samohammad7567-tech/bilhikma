import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import 'test_pair_badge.dart';

class TestPairTile extends StatelessWidget {
  const TestPairTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.badge,
    this.isMuted = false,
  });

  final String text;

  final bool isSelected;

  final bool isMuted;

  final int? badge;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int? badge = this.badge;

    return Material(
      color: isMuted
          ? colors.surfaceContainerHighest
          : colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? colors.secondary : Colors.transparent,
              width: 1.6.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: AppTheme.styles(
                    context,
                  ).cardBlurb.copyWith(color: colors.onSurface),
                ),
              ),

              if (badge != null) ...<Widget>[
                SizedBox(width: 8.w),
                TestPairBadge(value: badge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
