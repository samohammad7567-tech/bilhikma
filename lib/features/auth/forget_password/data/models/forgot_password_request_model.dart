import '../../../../../core/enums/reset_channel_enum.dart';

class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({
    required this.identifier,
    required this.channel,
  });

  final String identifier;
  final ResetChannel channel;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'identifier': identifier,
    'channel': channel.key,
  };
}
