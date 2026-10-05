import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/password_requirement_enum.dart';
import '../themes/app_theme.dart';
import 'password_requirement_row.dart';

/// Live checklist of [PasswordRequirement] shown under a password field.
///
/// Rebuilt from [password] on every keystroke, so a rule flips to a check the
/// moment it is met and back to a circle if the user deletes what satisfied it.
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

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
          Text(
            'password_requirements_title'.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelMedium,
          ),

          SizedBox(height: 4.h),

          for (final PasswordRequirement requirement
              in PasswordRequirement.values)
            PasswordRequirementRow(
              requirement: requirement,
              isSatisfied: requirement.isSatisfiedBy(password),
            ),
        ],
      ),
    );
  }
}
