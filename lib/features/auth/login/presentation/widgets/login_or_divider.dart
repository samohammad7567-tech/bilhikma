import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/app_theme.dart';

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final Color rule = Theme.of(context).colorScheme.secondary;
    final double gap = 40.w;

    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(thickness: 1.h, color: rule),
        ),
        SizedBox(width: gap),
        Text('or'.tr(), style: AppTheme.styles(context).bodyLarge),
        SizedBox(width: gap),
        Expanded(
          child: Divider(thickness: 1.h, color: rule),
        ),
      ],
    );
  }
}
