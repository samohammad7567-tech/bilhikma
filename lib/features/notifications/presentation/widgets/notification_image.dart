import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image_viewer.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/screen_scale.dart';
import '../../../../core/widgets/app_skeleton_box.dart';

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
    final double maxHeight = MyScreenSize.heightFraction(
      context,
      _maxHeightFactor,
    );

    return Semantics(
      button: true,
      label: LangKeys.viewImage.tr(),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => AppImageViewer.open(context, url: url, heroTag: heroTag),
        // The hint is inside the clip, so it disappears with the image when the
        // url fails to load.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
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
                    placeholder: AppSkeletonBox(
                      height: (170).h(context),
                      radius: _radius,
                    ),
                  ),
                ),
              ),

              PositionedDirectional(
                bottom: (8).h(context),
                end: (8).h(context),
                child: Container(
                  padding: EdgeInsets.all((6).r(context)),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.zoom_out_map,
                    size: (16).r(context),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
