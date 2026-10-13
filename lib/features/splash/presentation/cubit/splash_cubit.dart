import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/device_session_service.dart';
import '../../../../core/services/screen_capture_policy.dart';
import '../../../../core/enums/device_session_status_enum.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInitial());
  static const Duration splashDuration = Duration(milliseconds: 4500);
  Future<void> start() async {
    emit(const SplashLoading());

    final DeviceSessionStatus status = await _resolveSession();

    await Future.wait(<Future<void>>[
      ScreenCapturePolicy.refresh(),
      Future<void>.delayed(splashDuration),
    ]);
    if (isClosed) return;

    emit(
      SplashCompleted(
        // The profile read above is also what catches a suspension taken while
        // the app was closed: it signs the student out, so the stored session
        // is checked once more rather than trusting the pre-flight answer.
        isLoggedIn:
            status == DeviceSessionStatus.valid &&
            DeviceSessionService.hasSession,
        noticeKey: status == DeviceSessionStatus.deviceMismatch
            ? 'session_bound_to_another_device'
            : null,
      ),
    );
  }

  Future<DeviceSessionStatus> _resolveSession() async {
    final DeviceSessionStatus status =
        await DeviceSessionService.validateCachedSession();

    if (status == DeviceSessionStatus.deviceMismatch) {
      await DeviceSessionService.clear();
    }
    return status;
  }
}
