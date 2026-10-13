import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../../data/models/download_log_item.dart';
import '../../data/repos/downloads_log_repo.dart';

part 'downloads_log_state.dart';

class DownloadsLogCubit extends Cubit<DownloadsLogState> {
  DownloadsLogCubit({this.repo = const DownloadsLogRepo()})
    : super(const DownloadsLogState()) {
    loadDownloads();
    DownloadedPdfsDataSource.revision.addListener(_onDownloadsChanged);
  }

  final DownloadsLogRepo repo;

  bool _isMutating = false;

  @override
  Future<void> close() {
    DownloadedPdfsDataSource.revision.removeListener(_onDownloadsChanged);
    return super.close();
  }

  Future<void> loadDownloads() async {
    emit(state.copyWith(status: DownloadsLogStatus.loading, clearError: true));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> deleteDownload(DownloadLogItem item) async {
    if (state.isBusy) return;

    _isMutating = true;
    emit(
      state.copyWith(
        deletingFileName: item.fileName,
        clearError: true,
        clearMessage: true,
      ),
    );

    try {
      await repo.deleteDownload(item.fileName);
      if (isClosed) return;

      emit(state.copyWith(clearDeleting: true, messageKey: 'download_deleted'));
      await _load();
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(clearDeleting: true, errorKey: ErrorMapper.map(error)),
      );
    } finally {
      _isMutating = false;
    }
  }

  Future<void> deleteAllDownloads() async {
    if (state.isBusy || state.items.isEmpty) return;

    _isMutating = true;
    emit(
      state.copyWith(isDeletingAll: true, clearError: true, clearMessage: true),
    );

    try {
      await repo.deleteAllDownloads();
      if (isClosed) return;

      emit(
        state.copyWith(clearDeleting: true, messageKey: 'downloads_cleared'),
      );
      await _load();
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(clearDeleting: true, errorKey: ErrorMapper.map(error)),
      );
    } finally {
      _isMutating = false;
    }
  }

  void _onDownloadsChanged() {
    if (_isMutating) return;

    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final List<DownloadLogItem> items = await repo.readDownloads();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: items.isEmpty
              ? DownloadsLogStatus.empty
              : DownloadsLogStatus.success,
          items: items,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(status: DownloadsLogStatus.failure, errorKey: error.key),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: DownloadsLogStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
