import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/login_header.dart';
import '../widgets/login_language_toggle.dart';
import 'login_form.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key, this.onForgotPassword});

  final void Function(String email)? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: ConstrainedBox(
              // minHeight fills the viewport; `spaceEvenly` distributes the
              // slack, so no `Expanded` (and no `IntrinsicHeight`) is needed.
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: LoginLanguageToggle(),
                  ),
                  const LoginHeader(),
                  LoginForm(onForgotPassword: onForgotPassword),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
