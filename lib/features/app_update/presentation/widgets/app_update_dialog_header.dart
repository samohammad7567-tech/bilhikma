import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppUpdateDialogHeader extends StatelessWidget {
  const AppUpdateDialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: (38).w(context),
          height: (38).h(context),
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular((10).r(context)),
          ),
          child: Icon(
            Icons.system_update_alt_rounded,
            size: (20).r(context),
            color: colors.onSecondary,
          ),
        ),

        SizedBox(width: (12).w(context)),

        Expanded(
          child: Text(
            'update_available'.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).sectionTitle,
          ),
        ),
      ],
    );
  }
}
