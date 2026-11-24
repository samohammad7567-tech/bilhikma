import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SettingsChoiceCard extends StatelessWidget {
  const SettingsChoiceCard({
    required this.imagePath,
    required this.title,
    required this.hint,
    required this.control,
    super.key,
  });

  final String imagePath;
  final String title;
  final String hint;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (12).w(context), vertical: (12).h(context)),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular((14).r(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(width: (12).w(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title.tr(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.rowTitle,
                    ),

                    SizedBox(height: (2).h(context)),

                    Text(
                      hint.tr(),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.cardCaption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: (12).h(context)),

          control,
        ],
      ),
    );
  }
}
