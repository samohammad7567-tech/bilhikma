import '../data_source/forget_password_data_source.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_otp_request_model.dart';

class ForgetPasswordRepo {
  const ForgetPasswordRepo({
    this.dataSource = const ForgetPasswordDataSource(),
  });

  final ForgetPasswordDataSource dataSource;

  int get codeLength => ForgetPasswordDataSource.codeLength;

  Future<ForgotPasswordResponseModel> requestCode(
    ForgotPasswordRequestModel request,
  ) => dataSource.requestCode(request);

  Future<void> verifyCode(VerifyOtpRequestModel request) =>
      dataSource.verifyCode(request);

  Future<void> resetPassword(ResetPasswordRequestModel request) =>
      dataSource.resetPassword(request);
}
