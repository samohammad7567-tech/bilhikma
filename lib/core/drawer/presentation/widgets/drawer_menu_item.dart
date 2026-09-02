import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../enums/drawer_destination_enum.dart';
import '../../../themes/app_theme.dart';

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    required this.destination,
    required this.onTap,
    super.key,
  });

  final DrawerDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: <Widget>[
            Icon(destination.icon, size: 22.w, color: colors.secondary),

            SizedBox(width: 16.w),

            Expanded(
              child: Text(
                destination.label.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
