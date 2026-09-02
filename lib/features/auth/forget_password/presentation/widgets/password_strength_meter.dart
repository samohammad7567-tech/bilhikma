import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/enums/password_strength_enum.dart';
import 'password_strength_segment.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.strength, super.key});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color tone = _toneOf(colors);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int index = 0; index < PasswordStrength.segments; index++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == PasswordStrength.segments - 1 ? 0 : 4.w,
                    ),
                    child: PasswordStrengthSegment(
                      isFilled: index < strength.filledSegments,
                      tone: tone,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            'password_strength'.tr(
              namedArgs: <String, String>{'level': strength.labelKey.tr()},
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelSmall.copyWith(color: tone),
          ),
        ],
      ),
    );
  }

  Color _toneOf(ColorScheme colors) => switch (strength) {
    PasswordStrength.none || PasswordStrength.weak => colors.error,
    PasswordStrength.fair => colors.tertiary,
    PasswordStrength.good => colors.primaryContainer,
    PasswordStrength.strong => colors.secondaryContainer,
  };
}
