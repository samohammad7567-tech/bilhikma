import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/screen_capture_service.dart';
import '../../data/models/security_event_model.dart';
import '../../data/repos/security_repo.dart';

part 'security_state.dart';

class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit({required this.repo, ScreenCaptureService? service})
    : _service = service ?? ScreenCaptureService.instance,
      super(const SecurityState()) {
    _subscription = _service.reports.listen(_onReport);
  }

  final SecurityRepo repo;
  final ScreenCaptureService _service;

  late final StreamSubscription<SecurityEventResponseModel> _subscription;

  int watchScreen(String screen, {int? contentId}) =>
      _service.pushScreen(screen, contentId: contentId);

  void unwatchScreen(int token) => _service.popScreen(token);

  void acknowledgeWarning() {
    if (state.status != SecurityStatus.warned) return;
    emit(state.copyWith(status: SecurityStatus.idle));
  }

  Future<void> _onReport(SecurityEventResponseModel response) async {
    if (response.accountSuspended) {
      await repo.endSession();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: SecurityStatus.suspended,
          eventId: response.eventId,
        ),
      );
      return;
    }

    if (!response.hasWarning || isClosed) return;

    emit(
      state.copyWith(
        status: SecurityStatus.warned,
        warningIssued: response.warningIssued,
        eventId: response.eventId,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
