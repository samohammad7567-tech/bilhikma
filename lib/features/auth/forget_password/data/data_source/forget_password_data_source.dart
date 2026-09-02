import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_envelope.dart';
import '../../../../../core/utils/error_mapper.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_otp_request_model.dart';

class ForgetPasswordDataSource {
  const ForgetPasswordDataSource({this.client = const ApiClient()});

  final ApiClient client;

  static const int codeLength = 6;

  Future<ForgotPasswordResponseModel> requestCode(
    ForgotPasswordRequestModel request,
  ) async {
    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
    );

    return ForgotPasswordResponseModel.fromJson(envelope.dataMap);
  }

  Future<void> verifyCode(VerifyOtpRequestModel request) async {
    try {
      await client.post(ApiEndpoints.sendPasswordOtp, data: request.toJson());
    } on AppException catch (error) {
      throw error.statusCode == 422 ? _badCode(error) : error;
    }
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      await client.post(ApiEndpoints.setNewPassword, data: request.toJson());
    } on AppException catch (error) {
      final bool isPasswordRejected =
          error.errorsFor('password').isNotEmpty ||
          error.errorsFor('password_confirmation').isNotEmpty;

      throw error.statusCode == 422 && !isPasswordRejected
          ? _badCode(error)
          : error;
    }
  }

  AppException _badCode(AppException error) => AppException(
    'invalid_or_expired_code',
    message: error.message,
    errors: error.errors,
    statusCode: error.statusCode,
  );
}
