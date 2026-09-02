part of 'forget_password_cubit.dart';

enum ForgetPasswordStatus { initial, loading, success, failure }

final class ForgetPasswordState {
  const ForgetPasswordState({
    this.status = ForgetPasswordStatus.initial,
    this.channel = ResetChannel.email,
    this.identifier = '',
    this.errorKey,
  });

  final ForgetPasswordStatus status;
  final ResetChannel channel;

  final String identifier;
  final String? errorKey;

  bool get isLoading => status == ForgetPasswordStatus.loading;

  bool get wantsEmailAddress => channel.wantsEmailAddress;

  ForgetPasswordState copyWith({
    ForgetPasswordStatus? status,
    ResetChannel? channel,
    String? identifier,
    String? errorKey,
  }) => ForgetPasswordState(
    status: status ?? this.status,
    channel: channel ?? this.channel,
    identifier: identifier ?? this.identifier,
    errorKey: errorKey,
  );
}
