import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/notification_kind_accents.dart';

class NotificationKindChip extends StatelessWidget {
  const NotificationKindChip({required this.kind, super.key});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final Color accent = NotificationKindAccents.of(context, kind);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: NotificationKindAccents.chipTint),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        kind.labelKey.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accent,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}
