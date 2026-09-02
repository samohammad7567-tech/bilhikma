import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import '../../../../core/widgets/ornamented_card.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/widgets/lesson_thumbnail.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../../core/themes/app_theme.dart';
import 'subject_book_details.dart';

class SubjectBookCard extends StatelessWidget {
  const SubjectBookCard({
    required this.book,
    required this.onDownload,
    required this.onPreview,
    super.key,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.isDownloaded = false,
  });

  final TextbookModel book;
  final VoidCallback onDownload;
  final VoidCallback onPreview;

  final bool isDownloading;
  final bool isPreviewing;

  final bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return OrnamentedCard(
      radius: 14.r,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const LessonThumbnail(mediaType: ContentType.article),

                SizedBox(width: 12.w),

                Expanded(child: SubjectBookDetails(book: book)),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          if (!isDownloaded) ...<Widget>[
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
          ],

          if (isDownloaded)
            CustomButton(
              onPressed: onPreview,
              text: 'preview_book'.tr(),
              width: double.infinity,
              height: 46.h,
              threeRadius: 8.r,
              lastRadius: 8.r,
              elevation: 0,
              isLoading: isPreviewing,
              loadingWidth: 22.w,
              loadingHeight: 22.w,
            )
          else
            CustomOutlineButton(
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
            ),
        ],
      ),
    );
  }
}
