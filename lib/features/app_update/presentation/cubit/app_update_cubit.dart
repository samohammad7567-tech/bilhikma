import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/app_version_status_enum.dart';
import '../../data/models/app_version_model.dart';
import '../../data/repos/app_update_repo.dart';

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({required this.repo}) : super(const AppUpdateInitial());

  final AppUpdateRepo repo;

  final Completer<void> _settled = Completer<void>();
  Future<void> get settled => _settled.future;

  Future<void> check() async {
    if (state is! AppUpdateInitial) return;

    emit(const AppUpdateChecking());

    final AppVersionModel? version = await repo.fetch();

    if (isClosed) {
      _markSettled();
      return;
    }
    emit(version == null ? const AppUpdateAllowed() : _verdict(version));

    _markSettled();
  }

  AppUpdateState _verdict(AppVersionModel version) => switch (version.status) {
    AppVersionStatus.ok => const AppUpdateAllowed(),
    AppVersionStatus.optionalUpdate => AppUpdateOptional(version),
    AppVersionStatus.forceUpdate ||
    AppVersionStatus.maintenance => AppUpdateBlocked(version),
  };
  void dismissOptional() {
    if (state is! AppUpdateOptional) return;
    emit(const AppUpdateAllowed());
  }

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
