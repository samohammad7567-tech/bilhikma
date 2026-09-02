import 'package:bilhikma/core/utils/current_user.dart';

import '../data_source/login_data_source.dart';
import '../../../../../core/models/auth_user_model.dart';
import '../../../../../core/enums/login_method_enum.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class LoginRepo {
  const LoginRepo({this.dataSource = const LoginDataSource()});

  final LoginDataSource dataSource;

  Future<LoginResponseModel> login(
    LoginRequestModel request, {
    required bool rememberMe,
  }) => dataSource.login(request, rememberMe: rememberMe);

  ({LoginMethod method, String identifier})? rememberedIdentity() =>
      dataSource.rememberedIdentity();

  bool get isRememberMeEnabled => dataSource.isRememberMeEnabled;

  AuthUserModel? cachedUser() => CurrentUser.cachedUser();
}
