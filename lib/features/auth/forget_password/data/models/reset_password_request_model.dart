class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.identifier,
    required this.code,
    required this.password,
  });

  final String identifier;
  final String code;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'identifier': identifier,
    'code': code,
    'password': password,
    'password_confirmation': password,
  };
}
