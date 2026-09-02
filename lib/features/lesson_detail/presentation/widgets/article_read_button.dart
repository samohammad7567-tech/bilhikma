import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class ArticleReadButton extends StatelessWidget {
  const ArticleReadButton({
    required this.isRead,
    required this.onMarkRead,
    super.key,
  });

  final bool isRead;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isRead) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle, size: 20.w, color: colors.secondary),

          SizedBox(width: 8.w),

          Flexible(
            child: Text(
              'article_read'.tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(
                context,
              ).labelStrong.copyWith(color: colors.secondary),
            ),
          ),
        ],
      );
    }

    return CustomButton(
      onPressed: onMarkRead,
      text: 'mark_article_read'.tr(),
      width: double.infinity,
      height: 46.h,
      threeRadius: 8.r,
      lastRadius: 8.r,
      backgroundColor: colors.secondary,
      textColor: colors.onSecondary,
      elevation: 0,
    );
  }
}
