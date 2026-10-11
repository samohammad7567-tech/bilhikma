import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';

class AppUpdateDialogHeader extends StatelessWidget {
  const AppUpdateDialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.system_update_alt_rounded,
            size: 20.w,
            color: colors.onSecondary,
          ),
        ),

        SizedBox(width: 12.w),

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
