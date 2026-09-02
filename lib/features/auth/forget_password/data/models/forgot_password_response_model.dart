import '../../../../../core/network/json_reader.dart';
import '../../../../../core/enums/reset_channel_enum.dart';

class ForgotPasswordResponseModel {
  const ForgotPasswordResponseModel({required this.channel});

  final ResetChannel channel;

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponseModel(
        channel: ResetChannel.fromJson(Json.asOptionalString(json['channel'])),
      );
}
