import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/app_top_bar.dart';
import '../cubit/forget_password_cubit.dart';
import '../widgets/reset_password_header.dart';
import 'forget_password_form.dart';

class ForgetPasswordBody extends StatelessWidget {
  const ForgetPasswordBody({super.key, this.onBack, this.onBackToLogin});

  final VoidCallback? onBack;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: AppTopBar(
              title: context.tr('forget_password_title'),
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
                  BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                    buildWhen:
                        (
                          ForgetPasswordState previous,
                          ForgetPasswordState current,
                        ) =>
                            previous.wantsEmailAddress !=
                            current.wantsEmailAddress,
                    builder:
                        (BuildContext context, ForgetPasswordState state) =>
                            ResetPasswordHeader(
                              headingKey: 'recover_account',
                              hintKey: state.wantsEmailAddress
                                  ? 'recover_account_email_hint'
                                  : 'recover_account_phone_hint',
                            ),
                  ),

                  SizedBox(height: 26.h),

                  ForgetPasswordForm(onBackToLogin: onBackToLogin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
