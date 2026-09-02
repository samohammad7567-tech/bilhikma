import '../../../../../core/enums/reset_channel_enum.dart';

class SetPasswordArgs {
  const SetPasswordArgs({required this.identifier, required this.channel});

  final String identifier;
  final ResetChannel channel;

  static SetPasswordArgs fromRoute(Object? arguments) =>
      arguments is SetPasswordArgs
      ? arguments
      : const SetPasswordArgs(identifier: '', channel: ResetChannel.email);
}
