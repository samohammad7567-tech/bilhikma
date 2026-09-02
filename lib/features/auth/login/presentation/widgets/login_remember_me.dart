import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/app_theme.dart';

class LoginRememberMe extends StatelessWidget {
  const LoginRememberMe({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double boxSize = 18.w;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: value ? colors.tertiary : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: value
                    ? colors.tertiary
                    : colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            child: value
                ? Icon(Icons.check, size: 14.w, color: colors.onTertiary)
                : null,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'remember_me'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(
                context,
              ).linkLabel.copyWith(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
