import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonTextSection extends StatelessWidget {
  const LessonTextSection({
    required this.headingKey,
    required this.body,
    super.key,
  });
  final String headingKey;

  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          headingKey.tr(),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).groupTitle,
        ),

        SizedBox(height: (8).h(context)),
        Text(
          body,
          textAlign: TextAlign.start,
          style: AppTheme.styles(context).cardBlurb,
        ),
      ],
    );
  }
}
