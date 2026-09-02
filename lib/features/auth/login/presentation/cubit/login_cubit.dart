import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/error_mapper.dart';
import '../../../../../core/enums/login_method_enum.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/repos/login_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({this.repo = const LoginRepo()}) : super(const LoginState()) {
    _restoreRememberedIdentity();
  }

  final LoginRepo repo;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void switchLoginMethod() {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: LoginStatus.initial, method: state.method.toggled),
    );
  }

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleRememberMe([bool? value]) =>
      emit(state.copyWith(rememberMe: value ?? !state.rememberMe));

  Future<void> submit() =>
      state.isEmailLogin ? submitViaEmail() : submitViaPhoneNumber();

  Future<void> submitViaPhoneNumber() => _submit(
    () => repo.login(
      LoginRequestModel.phone(
        phone: phoneController.text.trim(),
        password: passwordController.text,
      ),
      rememberMe: state.rememberMe,
    ),
  );

  Future<void> submitViaEmail() => _submit(
    () => repo.login(
      LoginRequestModel.email(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
      rememberMe: state.rememberMe,
    ),
  );
  Future<void> _submit(Future<LoginResponseModel> Function() request) async {
    final FormState? form = formKey.currentState;
    if (form == null || !form.validate()) return;
    if (state.isLoading) return;

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final LoginResponseModel session = await request();
      if (isClosed) return;
      emit(state.copyWith(status: LoginStatus.success, session: session));
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: LoginStatus.failure, errorKey: error.message),
      );
    } catch (error, stackTrace) {
      if (isClosed) return;

      debugPrint('LoginCubit: unexpected error: $error\n$stackTrace');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorKey: 'something_went_wrong',
        ),
      );
    }
  }

  void _restoreRememberedIdentity() {
    final ({LoginMethod method, String identifier})? identity = repo
        .rememberedIdentity();
    if (identity == null) return;

    if (identity.method.isEmail) {
      emailController.text = identity.identifier;
    } else {
      phoneController.text = identity.identifier;
    }

    emit(state.copyWith(rememberMe: true, method: identity.method));
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
