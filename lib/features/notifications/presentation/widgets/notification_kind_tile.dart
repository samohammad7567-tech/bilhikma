import 'package:flutter/material.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/notification_tone_palette.dart';
import '../../../../core/widgets/app_icon.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class NotificationKindTile extends StatelessWidget {
  const NotificationKindTile({
    required this.kind,
    required this.tone,
    super.key,
  });

  final NotificationKind kind;
  final NotificationTonePalette tone;

  static const double size = 40;
  static const Color _tileColour = AppColors.creamCard;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular((10).r(context));
    if (kind.hasOwnTile) {
      return ClipRRect(
        borderRadius: radius,
        child: AppIcon(
          asset: kind.imagePath,
          size: size,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _tileColour, borderRadius: radius),
      child: Padding(
        padding: EdgeInsets.all((9).r(context)),
        child: AppIcon(
          asset: kind.imagePath,
          size: (22).r(context),
          fit: BoxFit.contain,
          color: tone.iconInk,
        ),
      ),
    );
  }
}
