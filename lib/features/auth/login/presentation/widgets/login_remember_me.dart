import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
    final double boxSize = 18;

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
              borderRadius: BorderRadius.circular((4).r(context)),
              border: Border.all(
                color: value
                    ? colors.tertiary
                    : colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            child: value
                ? Icon(Icons.check, size: (14).r(context), color: colors.onTertiary)
                : null,
          ),
          SizedBox(width: (8).w(context)),
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
