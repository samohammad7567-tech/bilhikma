import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../../../core/widgets/app_icon.dart';

class NotificationKindTile extends StatelessWidget {
  const NotificationKindTile({
    required this.kind,
    required this.tone,
    super.key,
  });

  final NotificationKind kind;
  final NotificationTonePalette tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        // The full-colour illustrations are drawn for a light ground, so the
        // tile stays light in both themes and the tone shows in the ring.
        color: const Color(0xffFBF7EF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: tone.accent, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(7.w),
        child: AppIcon(
          asset: kind.imagePath,
          size: 30.w,
          color: kind.hasMonochromeIcon ? tone.accent : null,
        ),
      ),
    );
  }
}
