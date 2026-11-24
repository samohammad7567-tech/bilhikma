import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class NotificationDayHeader extends StatelessWidget {
  const NotificationDayHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: (14).h(context), bottom: (8).h(context)),
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
