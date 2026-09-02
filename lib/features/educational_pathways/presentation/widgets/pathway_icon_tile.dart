import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_icon.dart';

class PathwayIconTile extends StatelessWidget {
  const PathwayIconTile({required this.asset, super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppIcon(asset: asset, size: 24.w, color: colors.onPrimary),
      ),
    );
  }
}
