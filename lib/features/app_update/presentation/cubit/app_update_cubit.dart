import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/app_version_status_enum.dart';
import '../../data/models/app_version_model.dart';
import '../../data/repos/app_update_repo.dart';

part 'app_update_state.dart';

/// Owns the launch-time verdict on this build.
///
/// It runs alongside the splash animation rather than before it, so the check
/// costs no visible startup time, and exposes [settled] so the hand-off from
/// the splash can wait for the answer instead of racing it.
class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({required this.repo}) : super(const AppUpdateInitial());

  final AppUpdateRepo repo;

  final Completer<void> _settled = Completer<void>();

  /// Completes once a verdict is in. Resolves even when the check failed — a
  /// failure is itself a verdict, and it is "continue".
  Future<void> get settled => _settled.future;

  Future<void> check() async {
    if (state is! AppUpdateInitial) return;

    emit(const AppUpdateChecking());

    final AppVersionModel? version = await repo.fetch();

    if (isClosed) {
      _markSettled();
      return;
    }

    // No answer means no reason to stop anyone. The data source has already
    // logged why.
    emit(version == null ? const AppUpdateAllowed() : _verdict(version));

    _markSettled();
  }

  AppUpdateState _verdict(AppVersionModel version) => switch (version.status) {
    AppVersionStatus.ok => const AppUpdateAllowed(),
    AppVersionStatus.optionalUpdate => AppUpdateOptional(version),
    AppVersionStatus.forceUpdate ||
    AppVersionStatus.maintenance => AppUpdateBlocked(version),
  };

  /// "Later" on the optional dialog. The offer is dropped for this launch and
  /// comes back on the next one, which is what the spec asks for.
  void dismissOptional() {
    if (state is! AppUpdateOptional) return;
    emit(const AppUpdateAllowed());
  }

  /// Opens the download link for whichever state is holding a version.
  ///
  /// Returns whether the handover succeeded. A failure re-emits the blocking
  /// state with an error key so the screen can say so and stay put — there is
  /// nowhere else for a forced user to go.
  Future<bool> openStore() async {
    final AppVersionModel? version = switch (state) {
      AppUpdateOptional(version: final AppVersionModel it) => it,
      AppUpdateBlocked(version: final AppVersionModel it) => it,
      _ => null,
    };

    final String? url = version?.storeUrl;

    if (version == null || url == null || url.isEmpty) {
      _reportStoreFailure(version);
      return false;
    }

    final bool opened = await repo.openStore(url);

    if (!opened) _reportStoreFailure(version);

    return opened;
  }

  void _reportStoreFailure(AppVersionModel? version) {
    if (isClosed || version == null) return;
    if (!version.status.blocksApp) return;

    emit(AppUpdateBlocked(version, errorKey: 'update_store_open_failed'));
  }

  void _markSettled() {
    if (!_settled.isCompleted) _settled.complete();
  }

  @override
  Future<void> close() {
    _markSettled();
    return super.close();
  }
}
