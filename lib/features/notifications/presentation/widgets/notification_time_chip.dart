import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../refactor/notification_formats.dart';
import '../../../../core/themes/app_theme.dart';

class NotificationTimeChip extends StatelessWidget {
  const NotificationTimeChip({required this.createdAt, super.key});

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final DateTime? createdAt = this.createdAt;
    if (createdAt == null) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: colors.tertiary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            Icons.access_time,
            size: 13.w,
            color: colors.onSurfaceVariant,
          ),
        ),

        SizedBox(width: 6.w),

        Text(
          NotificationFormats.relativeTime(createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardCaption,
        ),
      ],
    );
  }
}
