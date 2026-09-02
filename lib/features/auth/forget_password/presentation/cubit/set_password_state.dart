part of 'set_password_cubit.dart';

enum SetPasswordStatus { initial, loading, success, failure }

enum OtpStatus { initial, verifying, verified, invalid }

final class SetPasswordState {
  const SetPasswordState({
    this.status = SetPasswordStatus.initial,
    this.codeStatus = OtpStatus.initial,
    this.code = '',
    this.strength = PasswordStrength.none,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.codeErrorKey,
    this.errorKey,
  });

  final SetPasswordStatus status;
  final OtpStatus codeStatus;
  final String code;
  final PasswordStrength strength;
  final bool obscurePassword;
  final bool obscureConfirm;

  final String? codeErrorKey;
  final String? errorKey;

  bool get isLoading => status == SetPasswordStatus.loading;

  bool get isVerifyingCode => codeStatus == OtpStatus.verifying;

  bool get isCodeVerified => codeStatus == OtpStatus.verified;

  bool get showStrength => !strength.isEmpty;

  SetPasswordState copyWith({
    SetPasswordStatus? status,
    OtpStatus? codeStatus,
    String? code,
    PasswordStrength? strength,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? codeErrorKey,
    String? errorKey,
    bool clearCodeError = false,
  }) => SetPasswordState(
    status: status ?? this.status,
    codeStatus: codeStatus ?? this.codeStatus,
    code: code ?? this.code,
    strength: strength ?? this.strength,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureConfirm: obscureConfirm ?? this.obscureConfirm,
    codeErrorKey: clearCodeError ? null : codeErrorKey ?? this.codeErrorKey,
    errorKey: errorKey,
  );
}
