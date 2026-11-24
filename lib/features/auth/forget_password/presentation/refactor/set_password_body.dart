import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_content_width.dart';
import '../../../../../core/widgets/app_top_bar.dart';
import '../widgets/reset_password_header.dart';
import 'set_password_form.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SetPasswordBody extends StatelessWidget {
  const SetPasswordBody({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (12).h(context)),
            child: AppTopBar(
              title: context.tr('set_password_title'),
              onBack: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),

          Expanded(
            child: AppContentWidth(
              maxWidth: 560,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB((40).w(context), (20).h(context), (40).w(context), (32).h(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const ResetPasswordHeader(
                      headingKey: 'new_password_heading',
                      hintKey: 'set_password_hint',
                    ),

                    SizedBox(height: (26).h(context)),

                    const SetPasswordForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
