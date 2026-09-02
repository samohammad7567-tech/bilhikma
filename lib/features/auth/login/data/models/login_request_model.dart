import '../../../../../core/enums/login_method_enum.dart';

class LoginRequestModel {
  const LoginRequestModel({
    required this.identifier,
    required this.password,
    required this.method,
  });

  const LoginRequestModel.phone({required String phone, required this.password})
    : identifier = phone,
      method = LoginMethod.phone;

  const LoginRequestModel.email({required String email, required this.password})
    : identifier = email,
      method = LoginMethod.email;

  final String identifier;
  final String password;
  final LoginMethod method;

  Map<String, dynamic> toJson() => <String, dynamic>{
    method.fieldName: identifier,
    'password': password,
  };
}
