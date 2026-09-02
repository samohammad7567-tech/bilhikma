import '../../../../core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/enums/notification_kind_enum.dart';

class NotificationKindTile extends StatelessWidget {
  const NotificationKindTile({required this.kind, super.key});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final bool isGreen = kind.isGreen;

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: isGreen
            ? AppColors.tileGreen
            : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppIcon(
          asset: kind.imagePath,
          size: 24.w,
          color: isGreen
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
