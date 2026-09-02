part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

final class LoginState {
  const LoginState({
    this.status = LoginStatus.initial,
    this.method = LoginMethod.phone,
    this.rememberMe = false,
    this.obscurePassword = true,
    this.errorKey,
    this.session,
  });

  final LoginStatus status;
  final LoginMethod method;

  final bool rememberMe;
  final bool obscurePassword;
  final String? errorKey;

  final LoginResponseModel? session;

  bool get isLoading => status == LoginStatus.loading;

  bool get isEmailLogin => method.isEmail;

  LoginState copyWith({
    LoginStatus? status,
    LoginMethod? method,
    bool? rememberMe,
    bool? obscurePassword,
    String? errorKey,
    LoginResponseModel? session,
  }) {
    final LoginStatus resolvedStatus = status ?? this.status;
    return LoginState(
      status: resolvedStatus,
      method: method ?? this.method,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorKey: resolvedStatus == LoginStatus.failure
          ? (errorKey ?? this.errorKey)
          : null,
      session: resolvedStatus == LoginStatus.success
          ? (session ?? this.session)
          : null,
    );
  }
}
