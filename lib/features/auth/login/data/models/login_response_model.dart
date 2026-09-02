import '../../../../../core/network/json_reader.dart';
import '../../../../../core/models/auth_user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.user,
  });

  final String accessToken;

  final String? refreshToken;
  final String tokenType;
  final AuthUserModel? user;

  bool get hasSession => accessToken.isNotEmpty;

  factory LoginResponseModel.fromData(Map<String, dynamic> data) =>
      LoginResponseModel(
        accessToken: Json.asString(data['access_token']),
        refreshToken: Json.asOptionalString(data['refresh_token']),
        tokenType: Json.asOptionalString(data['token_type']) ?? 'Bearer',
        user: data['user'] is Map
            ? AuthUserModel.fromJson(Json.asMap(data['user']))
            : null,
      );
}
