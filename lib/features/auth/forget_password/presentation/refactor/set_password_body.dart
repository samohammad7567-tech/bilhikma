import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/app_top_bar.dart';
import '../widgets/reset_password_header.dart';
import 'set_password_form.dart';

class SetPasswordBody extends StatelessWidget {
  const SetPasswordBody({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: AppTopBar(
              title: context.tr('set_password_title'),
              onBack: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(40.w, 20.h, 40.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const ResetPasswordHeader(
                    headingKey: 'new_password_heading',
                    hintKey: 'set_password_hint',
                  ),

                  SizedBox(height: 26.h),

                  const SetPasswordForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
