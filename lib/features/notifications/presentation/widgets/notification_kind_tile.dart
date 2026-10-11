import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/app_colors.dart';
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

  static const double size = 40;

  /// The ground the artwork is authored against — the two tiles baked into
  /// their own artwork are this exact colour. It stays light in both themes,
  /// which is why [NotificationTonePalette.iconInk] stays dark.
  static const Color _tileColour = AppColors.creamCard;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(10.r);

    // Artwork that ships with its own tile is drawn edge to edge, so the
    // baked tile is the tile — nesting it inside another one shows as a
    // square of slightly the wrong cream.
    if (kind.hasOwnTile) {
      return ClipRRect(
        borderRadius: radius,
        child: AppIcon(
          asset: kind.imagePath,
          size: size.w,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(color: _tileColour, borderRadius: radius),
      child: Padding(
        padding: EdgeInsets.all(9.w),
        // Contain, not the default fill: the artwork is not all square —
        // the content glyph is 19x12, and a square box would stretch it.
        child: AppIcon(
          asset: kind.imagePath,
          size: 22.w,
          fit: BoxFit.contain,
          color: tone.iconInk,
        ),
      ),
    );
  }
}
