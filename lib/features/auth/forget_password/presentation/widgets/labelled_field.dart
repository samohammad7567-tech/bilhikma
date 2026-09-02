import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_theme.dart';

class LabelledField extends StatelessWidget {
  const LabelledField({required this.labelKey, required this.child, super.key});

  final String labelKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          labelKey.tr(),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).labelStrong,
        ),

        SizedBox(height: 8.h),

        child,
      ],
    );
  }
}
