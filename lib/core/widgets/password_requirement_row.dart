import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/password_requirement_enum.dart';
import '../themes/app_theme.dart';

/// A single rule line: an empty circle while unmet, a check once met.
class PasswordRequirementRow extends StatelessWidget {
  const PasswordRequirementRow({
    required this.requirement,
    required this.isSatisfied,
    super.key,
  });

  final PasswordRequirement requirement;
  final bool isSatisfied;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color tone = isSatisfied
        ? colors.primaryContainer
        : colors.onSurfaceVariant;

    return Semantics(
      checked: isSatisfied,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSatisfied
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                key: ValueKey<bool>(isSatisfied),
                size: 15.w,
                color: tone,
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: Text(
                requirement.labelKey.tr(namedArgs: requirement.labelArgs),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(
                  context,
                ).labelSmall.copyWith(color: tone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
