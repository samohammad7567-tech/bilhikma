import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';

class NotificationDayHeader extends StatelessWidget {
  const NotificationDayHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          label,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).rowTitle,
        ),
      ),
    );
  }
}
