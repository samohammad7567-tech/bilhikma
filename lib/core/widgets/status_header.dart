import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class StatusHeader extends StatelessWidget {
  const StatusHeader({required this.title, required this.note, super.key});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).statusTitle,
        ),
        SizedBox(height: (16).h(context)),
        Text(
          note,
          textAlign: TextAlign.center,
          style: AppTheme.styles(context).note,
        ),
      ],
    );
  }
}
