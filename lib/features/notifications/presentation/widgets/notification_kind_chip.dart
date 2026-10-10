import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/notification_tone_palette.dart';

/// Names the category in words, so the card is still identifiable to anyone
/// who cannot tell the tones apart.
class NotificationKindChip extends StatelessWidget {
  const NotificationKindChip({
    required this.kind,
    required this.tone,
    super.key,
  });

  final NotificationKind kind;
  final NotificationTonePalette tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: tone.accent,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        kind.labelKey.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: tone.onAccent,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}
