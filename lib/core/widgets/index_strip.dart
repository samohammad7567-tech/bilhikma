import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';

class IndexStrip extends StatelessWidget {
  const IndexStrip({required this.order, super.key});

  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 26.w),
      color: Theme.of(context).colorScheme.tertiary,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 10.h, left: 4.w, right: 4.w),
      child: Text(
        '$order',
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).rowTitle.copyWith(color: Theme.of(context).colorScheme.onTertiary),
      ),
    );
  }
}
