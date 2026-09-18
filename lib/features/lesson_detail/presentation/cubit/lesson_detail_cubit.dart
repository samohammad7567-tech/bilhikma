import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/enums/media_source_enum.dart';
import '../../../../core/models/lesson_progress_model.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../../data/data_source/lesson_detail_data_source.dart';
import '../../data/data_source/lesson_playback_data_source.dart';
import '../../data/models/lesson_attachment_model.dart';
import '../../data/models/lesson_detail_model.dart';
import '../../data/models/lesson_playback_state_model.dart';
import '../../data/repos/lesson_detail_repo.dart';

part 'lesson_detail_state.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit({
    required this.id,
    this.type = ContentType.video,
    LessonDetailRepo? repo,
    this.playbackStore = const LessonPlaybackDataSource(),
  }) : repo = repo ?? LessonDetailRepo(),
       super(const LessonDetailState()) {
    loadLesson();
    DownloadedPdfsDataSource.revision.addListener(_onDownloadsChanged);
  }

  final int id;

  final ContentType type;

  final LessonDetailRepo repo;
  final LessonPlaybackDataSource playbackStore;

  bool _isReporting = false;
  PlaybackAccess? _access;
  bool _isProgressHalted = false;
  static const Duration _correctionCooldown = Duration(seconds: 5);

  DateTime? _correctedAt;

  @override
  Future<void> close() {
    DownloadedPdfsDataSource.revision.removeListener(_onDownloadsChanged);
    return super.close();
  }

  Future<void> loadLesson() async {
    _isProgressHalted = false;
    _access = null;

    emit(state.copyWith(status: LessonDetailStatus.loading, clearError: true));

    try {
      final LessonDetailModel detail = await repo.fetchLesson(id);
      if (isClosed) return;

      final LessonPlaybackStateModel restored = _restoredCounter(detail);

      emit(
        state.copyWith(
          status: LessonDetailStatus.success,
          detail: detail,
          progress: detail.progress,
          isLocked: detail.isLocked,
          positionSeconds: restored.positionSeconds,
          checkpointIndex: restored.nextCheckpointIndex,
          watchedDeltaSeconds: restored.watchedDeltaSeconds,
          clearError: true,
        ),
      );

      await _refreshDownloadedAttachments();
      await _prefetchAccess(detail);
    } on AppException catch (error) {
      if (isClosed) return;
      _emitFailure(error);
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LessonDetailStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  LessonPlaybackStateModel _restoredCounter(LessonDetailModel detail) {
    final LessonPlaybackStateModel stored = playbackStore.read(id);
    if (stored.positionSeconds > 0 || stored.nextCheckpointIndex > 0) {
      return stored;
    }

    if (detail.progress.isCompleted) return stored;

    final int credited = detail.progress.maxPositionSeconds;

    return stored.copyWith(
      positionSeconds: credited,
      nextCheckpointIndex: detail.checkpoints
          .where((int checkpoint) => checkpoint <= credited)
          .length,
    );
  }

  void _emitFailure(AppException error) => emit(
    state.copyWith(
      status: LessonDetailStatus.failure,
      isLocked: error.statusCode == 403,
      errorKey: error.key,
      errorMessage: error.message,
    ),
  );
  Future<void> _prefetchAccess(LessonDetailModel detail) async {
    if (!detail.isPlayable || detail.isLocked) return;

    try {
      final PlaybackAccess access = await repo.requestPlayback(id);
      if (isClosed) return;

      _access = access;
      emit(state.copyWith(playbackSource: access.source));
    } catch (_) {
      return;
    }
  }

  Future<void> preparePlayback() async {
    final LessonDetailModel? detail = state.detail;
    if (detail == null || !detail.isPlayable || state.isPreparingPlayback) {
      return;
    }
    final PlaybackAccess? ready = _access;
    if (ready != null) {
      emit(
        state.copyWith(playbackUrl: ready.url, playbackSource: ready.source),
      );
      return;
    }

    emit(state.copyWith(isPreparingPlayback: true));

    try {
      final PlaybackAccess access = await repo.requestPlayback(id);
      if (isClosed) return;

      _access = access;

      emit(
        state.copyWith(
          playbackUrl: access.url,
          playbackSource: access.source,
          isPreparingPlayback: false,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isPreparingPlayback: false,
          isLocked: error.statusCode == 403 || state.isLocked,
          messageKey: error.key,
          message: error.message,
        ),
      );
    }
  }

  Future<void> onPlaybackTick({
    required int positionSeconds,
    required int playedSeconds,
  }) async {
    if (state.detail == null || isClosed) return;

    emit(
      state.copyWith(
        positionSeconds: positionSeconds,
        watchedDeltaSeconds: state.watchedDeltaSeconds + playedSeconds,
      ),
    );

    await _persistCounter();
    await _reportDueCheckpoint();
  }

  Future<void> onMediaEnded(int durationSeconds) async {
    if (state.detail == null || isClosed) return;

    emit(state.copyWith(positionSeconds: durationSeconds));

    await _persistCounter();
    await _reportDueCheckpoint(atEnd: true);
  }

  Future<void> _reportDueCheckpoint({bool atEnd = false}) async {
    final int? checkpoint = state.nextCheckpointSeconds;
    if (checkpoint == null || _isReporting || _isProgressHalted) return;
    if (!atEnd && state.positionSeconds < checkpoint) return;
    if (_isCoolingDown) return;

    await _sendCheckpoint(checkpoint);
  }

  bool get _isCoolingDown {
    final DateTime? correctedAt = _correctedAt;
    if (correctedAt == null) return false;

    return DateTime.now().difference(correctedAt) < _correctionCooldown;
  }

  Future<void> _sendCheckpoint(int positionSeconds) async {
    _isReporting = true;
    final int sentDelta = state.watchedDeltaSeconds;

    try {
      final ProgressResult result = await repo.reportProgress(
        id,
        ProgressHeartbeatRequestModel(
          positionSeconds: positionSeconds,
          watchedDeltaSeconds: sentDelta,
        ),
      );
      if (isClosed) return;

      if (result.seekRejected) {
        _applyCorrection(result.allowedPositionSeconds, result.progress);
        return;
      }

      final int carried = state.watchedDeltaSeconds - sentDelta;

      emit(
        state.copyWith(
          progress: result.progress,
          checkpointIndex: state.checkpointIndex + 1,
          watchedDeltaSeconds: carried < 0 ? 0 : carried,
        ),
      );

      await _persistCounter();

      if (state.hasReportedEveryCheckpoint && state.progress.isCompleted) {
        playbackStore.clear(id);
      }
    } on AppException catch (error) {
      if (isClosed) return;
      if (_isRefusal(error)) _isProgressHalted = true;

      emit(state.copyWith(messageKey: error.key, message: error.message));
    } finally {
      _isReporting = false;
    }
  }

  static bool _isRefusal(AppException error) =>
      error.statusCode == 403 || error.statusCode == 404;

  void _applyCorrection(
    int? allowedPositionSeconds, [
    LessonProgressModel? progress,
  ]) {
    final int target =
        allowedPositionSeconds ?? state.progress.maxPositionSeconds;

    _correctedAt = DateTime.now();

    emit(
      state.copyWith(
        progress: progress,
        positionSeconds: target,
        watchedDeltaSeconds: 0,
        correctionSeconds: target,
        correctionRevision: state.correctionRevision + 1,
      ),
    );

    unawaited(_persistCounter());
  }

  Future<void> _persistCounter() => playbackStore.write(
    LessonPlaybackStateModel(
      contentId: id,
      positionSeconds: state.positionSeconds,
      watchedDeltaSeconds: state.watchedDeltaSeconds,
      nextCheckpointIndex: state.checkpointIndex,
    ),
  );

  Future<void> markArticleRead() async {
    if (state.isArticleRead || _isReporting) return;

    _isReporting = true;

    try {
      final ProgressResult result = await repo.reportProgress(
        id,
        const ProgressHeartbeatRequestModel(positionSeconds: 0),
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          progress: result.progress,
          messageKey: 'article_read_done',
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(messageKey: error.key, message: error.message));
    } finally {
      _isReporting = false;
    }
  }

  Future<void> downloadAttachment(LessonAttachmentModel file) async {
    if (state.downloadingAttachmentId != null) return;
    if (state.isAttachmentDownloaded(file.id)) return;

    emit(state.copyWith(downloadingAttachmentId: file.id));

    try {
      final File saved = await repo.downloadAttachment(id, file);
      if (isClosed) return;

      emit(
        state.copyWith(
          clearAttachmentBusy: true,
          messageKey: saved.existsSync()
              ? 'book_downloaded'
              : 'book_download_failed',
        ),
      );

      await _refreshDownloadedAttachments();
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearAttachmentBusy: true,
          messageKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  Future<String?> prepareAttachmentPreview(LessonAttachmentModel file) async {
    if (state.previewingAttachmentId != null) return null;

    emit(state.copyWith(previewingAttachmentId: file.id));

    try {
      final File ready = await repo.fetchAttachmentForPreview(id, file);
      if (isClosed) return null;

      emit(state.copyWith(clearAttachmentBusy: true));
      return ready.existsSync() ? ready.path : null;
    } catch (error) {
      if (isClosed) return null;
      emit(
        state.copyWith(
          clearAttachmentBusy: true,
          messageKey: ErrorMapper.map(error),
        ),
      );
      return null;
    }
  }

  void _onDownloadsChanged() => unawaited(_refreshDownloadedAttachments());

  Future<void> _refreshDownloadedAttachments() async {
    final LessonDetailModel? detail = state.detail;
    if (detail == null || detail.attachments.isEmpty) return;

    final Set<int> downloaded = await repo.downloadedAttachmentIds(
      id,
      detail.attachments.map((LessonAttachmentModel file) => file.id),
    );
    if (isClosed) return;

    emit(state.copyWith(downloadedAttachmentIds: downloaded));
  }

  void togglePlayback() => emit(state.copyWith(isPlaying: !state.isPlaying));

  void setVideoFullscreen(bool value) {
    if (state.isVideoFullscreen == value) return;
    emit(state.copyWith(isVideoFullscreen: value));
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));

  void clearMessage() => emit(state.copyWith(clearMessage: true));
}
