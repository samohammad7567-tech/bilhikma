import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ArticleReadButton extends StatelessWidget {
  const ArticleReadButton({
    required this.isRead,
    required this.onMarkRead,
    super.key,
    this.isSaving = false,
  });

  final bool isRead;
  final bool isSaving;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isRead) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle, size: (20).r(context), color: colors.secondary),

          SizedBox(width: (8).w(context)),

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
      height: (46).h(context),
      threeRadius: 8,
      lastRadius: 8,
      backgroundColor: colors.secondary,
      textColor: colors.onSecondary,
      elevation: (0).r(context),
      isLoading: isSaving,
    );
  }
}
