import 'dart:convert';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/constants/cache_keys.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_envelope.dart';
import '../../../../../core/services/device_service.dart';
import '../../../../../core/services/device_session_service.dart';
import '../../../../../core/services/dio_service.dart';
import '../../../../../core/services/push_notification_service.dart';
import '../../../../../core/services/screen_capture_policy.dart';
import '../../../../../core/utils/cache_util.dart';
import '../../../../../core/utils/error_mapper.dart';
import '../../../../../core/models/auth_user_model.dart';
import '../../../../../core/enums/login_method_enum.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class LoginDataSource {
  const LoginDataSource({this.client = const ApiClient()});

  final ApiClient client;

  static const String tokenKey = DeviceSessionService.tokenKey;
  static const String refreshTokenKey = DeviceSessionService.refreshTokenKey;

  Future<LoginResponseModel> login(
    LoginRequestModel request, {
    required bool rememberMe,
  }) async {
    await DeviceService.ensureInitialized();

    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.login,
      data: <String, dynamic>{
        ...request.toJson(),
        ...DeviceSessionService.loginPayload(),
      },
    );

    final LoginResponseModel session = LoginResponseModel.fromData(
      envelope.dataMap,
    );

    if (!session.hasSession) {
      throw const AppException('something_went_wrong');
    }

    await _persistSession(
      session,
      identifier: request.identifier,
      method: request.method,
      remember: rememberMe,
    );

    return session;
  }

  ({LoginMethod method, String identifier})? rememberedIdentity() {
    if (!isRememberMeEnabled) return null;

    final Object? identifier = CacheUtil.get(
      key: CacheKeys.rememberedIdentifierKey,
    );
    if (identifier is! String || identifier.isEmpty) return null;

    return (
      method: LoginMethod.fromStorage(
        CacheUtil.get(key: CacheKeys.rememberedMethodKey),
      ),
      identifier: identifier,
    );
  }

  bool get isRememberMeEnabled =>
      CacheUtil.get(key: CacheKeys.rememberMeKey) == true;

  Future<void> _persistSession(
    LoginResponseModel session, {
    required String identifier,
    required LoginMethod method,
    required bool remember,
  }) async {
    await CacheUtil.setString(key: tokenKey, value: session.accessToken);
    DioService.updateToken(session.accessToken);
    await DeviceSessionService.bind(session.accessToken);

    await PushNotificationService.registerToken();

    final String? refreshToken = session.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await CacheUtil.setString(key: refreshTokenKey, value: refreshToken);
    }
    await _cacheUser(session.user);

    await ScreenCapturePolicy.resolve(
      canCaptureScreen: session.user?.canCaptureScreen ?? false,
    );

    await CacheUtil.setBool(key: CacheKeys.rememberMeKey, value: remember);
    if (remember) {
      await CacheUtil.setString(
        key: CacheKeys.rememberedIdentifierKey,
        value: identifier,
      );
      await CacheUtil.setString(
        key: CacheKeys.rememberedMethodKey,
        value: method.name,
      );
    } else {
      CacheUtil.remove(key: CacheKeys.rememberedIdentifierKey);
      CacheUtil.remove(key: CacheKeys.rememberedMethodKey);
    }
  }

  Future<void> _cacheUser(AuthUserModel? user) async {
    if (user == null) return;

    await CacheUtil.setString(
      key: CacheKeys.cachedUserKey,
      value: jsonEncode(user.toJson()),
    );
  }
}
