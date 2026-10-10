import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../refactor/notification_formats.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/notification_tone_palette.dart';

class NotificationTimeChip extends StatelessWidget {
  const NotificationTimeChip({
    required this.createdAt,
    required this.tone,
    super.key,
  });

  final DateTime? createdAt;
  final NotificationTonePalette tone;

  @override
  Widget build(BuildContext context) {
    final DateTime? createdAt = this.createdAt;
    if (createdAt == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: tone.accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(Icons.access_time, size: 13.w, color: tone.body),
        ),

        SizedBox(width: 6.w),

        Text(
          NotificationFormats.relativeTime(createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(
            context,
          ).cardCaption.copyWith(color: tone.body),
        ),
      ],
    );
  }
}
