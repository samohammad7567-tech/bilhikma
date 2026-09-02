import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/app_icon.dart';

class FieldIconBox extends StatelessWidget {
  const FieldIconBox({required this.asset, super.key, this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget box = AppIcon(
      asset: asset,
      size: 17.w,
      color: colors.secondary,
      padding: EdgeInsets.all(12.w),
    );

    if (onTap == null) return box;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}
