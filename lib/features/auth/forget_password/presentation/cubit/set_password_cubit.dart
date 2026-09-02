import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/error_mapper.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/models/verify_otp_request_model.dart';
import '../../data/repos/forget_password_repo.dart';
import '../../../../../core/enums/password_strength_enum.dart';
import '../refactor/set_password_args.dart';

part 'set_password_state.dart';

class SetPasswordCubit extends Cubit<SetPasswordState> {
  SetPasswordCubit({required this.args, this.repo = const ForgetPasswordRepo()})
    : super(const SetPasswordState());

  final SetPasswordArgs args;
  final ForgetPasswordRepo repo;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  int get codeLength => repo.codeLength;

  void codeChanged(String code) {
    emit(
      state.copyWith(
        code: code,
        codeStatus: OtpStatus.initial,
        clearCodeError: true,
      ),
    );

    if (code.length == codeLength) verifyCode();
  }

  void passwordChanged(String password) =>
      emit(state.copyWith(strength: PasswordStrength.of(password)));

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleConfirmVisibility() =>
      emit(state.copyWith(obscureConfirm: !state.obscureConfirm));

  Future<void> verifyCode() async {
    if (state.code.length != codeLength || state.isVerifyingCode) return;

    emit(state.copyWith(codeStatus: OtpStatus.verifying, clearCodeError: true));

    try {
      await repo.verifyCode(
        VerifyOtpRequestModel(identifier: args.identifier, code: state.code),
      );
      if (isClosed) return;

      emit(state.copyWith(codeStatus: OtpStatus.verified));
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          codeStatus: OtpStatus.invalid,
          codeErrorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  Future<void> submit() async {
    final FormState? form = formKey.currentState;
    if (form == null) return;

    final bool codeIsValid = _validateCode();
    if (!form.validate() || !codeIsValid) return;
    if (state.isLoading) return;

    emit(state.copyWith(status: SetPasswordStatus.loading));

    try {
      await repo.resetPassword(
        ResetPasswordRequestModel(
          identifier: args.identifier,
          code: state.code,
          password: passwordController.text,
        ),
      );
      if (isClosed) return;

      emit(state.copyWith(status: SetPasswordStatus.success));
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: SetPasswordStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  bool _validateCode() {
    if (state.code.isEmpty) {
      emit(state.copyWith(codeErrorKey: 'verification_code_required'));
      return false;
    }

    if (state.code.length != codeLength) {
      emit(state.copyWith(codeErrorKey: 'verification_code_length'));
      return false;
    }

    return state.codeStatus != OtpStatus.invalid;
  }

  @override
  Future<void> close() {
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    return super.close();
  }
}
