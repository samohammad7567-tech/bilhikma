import 'package:flutter/material.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/book_preview_args.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../data/models/download_log_item.dart';
import '../cubit/downloads_log_cubit.dart';

class DownloadsLogActions {
  DownloadsLogActions._();

  static Future<void> openItem(
    BuildContext context,
    DownloadLogItem item,
  ) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.bookPreview,
      arguments: BookPreviewArgs(
        filePath: item.filePath,
        title: item.title,
        resumeKey: item.resumeKey,
      ),
    );
  }

  static Future<void> confirmDelete(
    BuildContext context,
    DownloadsLogCubit cubit,
    DownloadLogItem item,
  ) async {
    final bool isConfirmed = await AppConfirmDialog.show(
      context,
      titleKey: 'delete_download',
      messageKey: 'delete_download_confirm',
      confirmKey: 'delete',
      messageArgs: <String, String>{'name': item.title},
    );

    if (isConfirmed) await cubit.deleteDownload(item);
  }

  static Future<void> confirmDeleteAll(
    BuildContext context,
    DownloadsLogCubit cubit,
  ) async {
    final bool isConfirmed = await AppConfirmDialog.show(
      context,
      titleKey: 'clear_all_downloads',
      messageKey: 'clear_downloads_confirm',
      confirmKey: 'clear_all',
    );

    if (isConfirmed) await cubit.deleteAllDownloads();
  }
}
