import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_image_viewer.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';

/// Notification banner image: shown whole (never cropped) and tappable to open
/// the full screen [AppImageViewer].
class NotificationImage extends StatelessWidget {
  const NotificationImage({
    required this.url,
    required this.heroTag,
    super.key,
  });

  final String url;
  final Object heroTag;

  /// Caps how much of the sheet a very tall image may take; the image is still
  /// shown complete inside it.
  static const double _maxHeightFactor = 0.42;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height * _maxHeightFactor;

    return Semantics(
      button: true,
      label: 'view_image'.tr(),
      excludeSemantics: true,
      // The hint is inside the clip, so it disappears with the image when the
      // url fails to load.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius.r),
        child: Stack(
          children: <Widget>[
            Hero(
              tag: heroTag,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: AppNetworkImage(
                  url: url,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorWidget: const SizedBox.shrink(),
                  placeholder: AppShimmer(
                    child: SkeletonBox(height: 170.h, radius: _radius.r),
                  ),
                ),
              ),
            ),

            PositionedDirectional(
              bottom: 8.h,
              end: 8.w,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.zoom_out_map,
                  size: 16.r,
                  color: Colors.white,
                ),
              ),
            ),

            // Above the image so the ripple is visible on tap.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      AppImageViewer.open(context, url: url, heroTag: heroTag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
