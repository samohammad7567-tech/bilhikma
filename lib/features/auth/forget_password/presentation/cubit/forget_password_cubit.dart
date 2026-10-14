import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/error_mapper.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/models/forgot_password_response_model.dart';
import '../../../../../core/enums/reset_channel_enum.dart';
import '../../data/repos/forget_password_repo.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit({this.repo = const ForgetPasswordRepo()})
    : super(const ForgetPasswordState());

  final ForgetPasswordRepo repo;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  /// Carries over the address already typed on the login screen, so the user
  /// does not type it twice. Ignores anything empty.
  void prefillEmail(String? email) {
    final String value = (email ?? '').trim();
    if (value.isEmpty) return;

    emailController.text = value;
  }

  Future<void> submit() async {
    final FormState? form = formKey.currentState;
    if (form == null || !form.validate()) return;
    if (state.isLoading) return;

    final String identifier = emailController.text.trim();

    emit(state.copyWith(status: ForgetPasswordStatus.loading));

    try {
      final ForgotPasswordResponseModel response = await repo.requestCode(
        ForgotPasswordRequestModel(
          identifier: identifier,
          channel: state.channel,
        ),
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ForgetPasswordStatus.success,
          identifier: identifier,

          channel: response.channel,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
