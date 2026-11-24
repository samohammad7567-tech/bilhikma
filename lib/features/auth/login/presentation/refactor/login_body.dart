import 'package:flutter/material.dart';

import '../../../../../core/utils/my_screen_size.dart';
import '../../../../../core/widgets/app_content_width.dart';
import '../widgets/login_header.dart';
import '../widgets/login_language_toggle.dart';
import 'login_form.dart';
import '../../../../../core/utils/screen_scale.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key, this.onForgotPassword});

  final void Function(String email)? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AppContentWidth(
            maxWidth: MyScreenSize.widthFraction(context, 0.85, max: 560),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: (40).w(context)),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: (8).h(context)),
                    const Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: LoginLanguageToggle(),
                    ),
                    const LoginHeader(),
                    LoginForm(onForgotPassword: onForgotPassword),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
