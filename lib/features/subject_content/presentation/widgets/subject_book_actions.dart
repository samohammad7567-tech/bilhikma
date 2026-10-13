import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import 'book_download_progress.dart';

class SubjectBookActions extends StatelessWidget {
  const SubjectBookActions({
    required this.onDownload,
    required this.onPreview,
    required this.onOpen,
    super.key,
    this.progress,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.isDownloaded = false,
  });

  final VoidCallback onDownload;
  final VoidCallback onPreview;
  final VoidCallback onOpen;

  final DownloadProgress? progress;

  final bool isDownloading;
  final bool isPreviewing;
  final bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    // A downloaded book is read from disk, so previewing it over the network
    // would only be slower: the single action becomes Open.
    if (isDownloaded) return _openButton(context);

    final DownloadProgress? active = progress;
    if (active != null && (isDownloading || isPreviewing)) {
      return BookDownloadProgress(
        progress: active,
        labelKey: isDownloading ? 'downloading_book' : 'preparing_book',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomButton(
          onPressed: onDownload,
          text: 'download_book'.tr(),
          width: double.infinity,
          height: 46.h,
          threeRadius: 8.r,
          lastRadius: 8.r,
          elevation: 0,
          isLoading: isDownloading,
          loadingWidth: 22.w,
          loadingHeight: 22.w,
        ),

        SizedBox(height: 10.h),

        Text(
          'book_watermark_note'.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardCaption,
        ),

        SizedBox(height: 10.h),

        _previewButton(context),
      ],
    );
  }

  Widget _openButton(BuildContext context) => CustomButton(
    onPressed: onOpen,
    text: 'open_book'.tr(),
    width: double.infinity,
    height: 46.h,
    threeRadius: 8.r,
    lastRadius: 8.r,
    elevation: 0,
    isLoading: isPreviewing,
    loadingWidth: 22.w,
    loadingHeight: 22.w,
  );

  Widget _previewButton(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return CustomOutlineButton(
      onPressed: onPreview,
      text: 'preview_book'.tr(),
      width: double.infinity,
      height: 46.h,
      threeRadius: 8.r,
      lastRadius: 8.r,
      borderColor: colors.outlineVariant,
      backgroundColor: colors.surfaceContainerLowest,
      textColor: colors.onSurface,
      isLoading: isPreviewing,
    );
  }
}
