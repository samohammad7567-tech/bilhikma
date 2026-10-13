part of 'downloads_log_cubit.dart';

enum DownloadsLogStatus { initial, loading, success, failure, empty }

final class DownloadsLogState {
  const DownloadsLogState({
    this.status = DownloadsLogStatus.initial,
    this.items = const <DownloadLogItem>[],
    this.deletingFileName,
    this.isDeletingAll = false,
    this.errorKey,
    this.messageKey,
  });

  final DownloadsLogStatus status;
  final List<DownloadLogItem> items;

  final String? deletingFileName;

  final bool isDeletingAll;

  final String? errorKey;
  final String? messageKey;

  bool get isFirstLoad =>
      status == DownloadsLogStatus.loading && items.isEmpty ||
      status == DownloadsLogStatus.initial;

  bool get hasFailed => status == DownloadsLogStatus.failure && items.isEmpty;

  bool get isEmpty => status == DownloadsLogStatus.empty && items.isEmpty;

  bool get isBusy => isDeletingAll || deletingFileName != null;

  bool get canDeleteAll => items.isNotEmpty && !isBusy;

  bool isDeleting(String fileName) =>
      isDeletingAll || deletingFileName == fileName;

  DownloadsLogState copyWith({
    DownloadsLogStatus? status,
    List<DownloadLogItem>? items,
    String? deletingFileName,
    bool? isDeletingAll,
    bool clearDeleting = false,
    String? errorKey,
    bool clearError = false,
    String? messageKey,
    bool clearMessage = false,
  }) => DownloadsLogState(
    status: status ?? this.status,
    items: items ?? this.items,
    deletingFileName: clearDeleting
        ? null
        : deletingFileName ?? this.deletingFileName,
    isDeletingAll: clearDeleting ? false : isDeletingAll ?? this.isDeletingAll,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    messageKey: clearMessage ? null : messageKey ?? this.messageKey,
  );
}
