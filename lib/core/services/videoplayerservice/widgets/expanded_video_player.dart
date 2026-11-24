import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/my_screen_size.dart';
import '../floating_video_controller.dart';
import '../video_item.dart';
import '../video_share.dart';
import '../video_playback.dart';
import '../video_player_options.dart';
import 'video_circle_icon_button.dart';
import 'video_controls_overlay.dart';
import 'video_details.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ExpandedVideoPlayer extends StatelessWidget {
  const ExpandedVideoPlayer({
    required this.controller,
    required this.options,
    super.key,
  });

  final FloatingVideoController controller;
  final FloatingVideoOptions options;

  @override
  Widget build(BuildContext context) {
    final VideoPlayback playback = controller.playback!;
    final VideoItem item = playback.item;

    final Widget videoStack = playback.buildSurface(
      key: controller.playerKey,
      overlay: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          VideoControlsOverlay(controller: controller, options: options),

          Positioned(
            top: (0).h(context),
            left: (0).w(context),
            right: (0).w(context),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all((8).r(context)),
                child: Row(
                  children: <Widget>[
                    VideoCircleIconButton(
                      icon: CupertinoIcons.chevron_down,
                      onTap: controller.minimize,
                    ),

                    const Spacer(),

                    if (VideoShare.isAvailable(item, options))
                      VideoCircleIconButton(
                        icon: Icons.share_rounded,
                        onTap: () => VideoShare.send(item, options),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final bool isLandscape = MyScreenSize.isLandscape(context);

    if (isLandscape) {
      return Material(color: options.backgroundColor, child: videoStack);
    }

    return Material(
      color: options.backgroundColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: options.resolveGradient(),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(aspectRatio: 16 / 9, child: videoStack),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB((20).w(context), (18).h(context), (20).w(context), (28).h(context)),
                  child:
                      options.detailsBuilder?.call(context, item) ??
                      VideoDetails(item: item, options: options),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
