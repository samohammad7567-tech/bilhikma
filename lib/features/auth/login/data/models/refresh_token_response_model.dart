import '../../../../../core/network/json_reader.dart';

class RefreshTokenResponseModel {
  const RefreshTokenResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;

  bool get hasSession => accessToken.isNotEmpty;

  factory RefreshTokenResponseModel.fromData(Map<String, dynamic> data) =>
      RefreshTokenResponseModel(
        accessToken: Json.asString(data['access_token']),
        refreshToken: Json.asOptionalString(data['refresh_token']),
        tokenType: Json.asOptionalString(data['token_type']) ?? 'Bearer',
      );
}
