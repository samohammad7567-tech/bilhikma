import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/app_theme.dart';
import 'login_remember_me.dart';

class LoginOptionsRow extends StatelessWidget {
  const LoginOptionsRow({
    required this.rememberMe,
    required this.onRememberMeChanged,
    super.key,
    this.onForgotPassword,
  });

  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: GestureDetector(
            onTap: onForgotPassword,
            child: Text(
              'forgot_password'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).linkLabel,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: LoginRememberMe(
            value: rememberMe,
            onChanged: onRememberMeChanged,
          ),
        ),
      ],
    );
  }
}
