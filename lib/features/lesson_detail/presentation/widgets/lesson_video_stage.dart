import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/utils/orientation/video_fullscreen_orientation.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/video_stage_sizing.dart';
import '../refactor/lesson_playback_controller.dart';
import '../refactor/lesson_playback_reporter.dart';
import '../refactor/lesson_video_stage_sync.dart';
import 'lesson_video_surface.dart';

class LessonVideoStage extends StatefulWidget {
  const LessonVideoStage({
    required this.url,
    required this.isPreparing,
    required this.onPrepare,
    required this.onTick,
    required this.onEnded,
    required this.resumeSeconds,
    required this.seekLimitSeconds,
    required this.correctionSeconds,
    required this.correctionRevision,
    required this.isFullscreen,
    required this.onFullscreenChanged,
    required this.speed,
    required this.onSpeedChanged,
    required this.isLessonCompleted,
    super.key,
  });
  final String? url;
  final bool isPreparing;
  final VoidCallback onPrepare;
  final void Function(int positionSeconds, int playedSeconds) onTick;
  final ValueChanged<int> onEnded;
  final int resumeSeconds;
  final int seekLimitSeconds;
  final int? correctionSeconds;
  final int correctionRevision;
  final bool isFullscreen;
  final ValueChanged<bool> onFullscreenChanged;
  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;
  final bool isLessonCompleted;
  @override
  State<LessonVideoStage> createState() => _LessonVideoStageState();
}

class _LessonVideoStageState extends State<LessonVideoStage>
    with AutomaticKeepAliveClientMixin<LessonVideoStage> {
  static const double _stageAspectRatio = 16 / 10;
  @override
  bool get wantKeepAlive => true;

  late final LessonPlaybackController _controller = LessonPlaybackController(
    reporter: LessonPlaybackReporter(
      onTick: (int position, int played) => widget.onTick(position, played),
      onEnded: (int duration) => widget.onEnded(duration),
    ),
    onChanged: () {
      if (mounted) setState(() {});
    },
  );

  late final LessonVideoStageSync _sync = LessonVideoStageSync(
    controller: _controller,
    applyOrientation: _applyOrientation,
  );
  bool _isMobile = true;

  @override
  void initState() {
    super.initState();
    _controller.speed = widget.speed.rate;
    unawaited(
      _controller.create(
        url: widget.url,
        resumeSeconds: widget.resumeSeconds,
        mounted: mounted,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MyScreenSize.isMobile(context);
  }

  @override
  void didUpdateWidget(LessonVideoStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(oldWidget: oldWidget, widget: widget, mounted: mounted);
  }

  @override
  void dispose() {
    if (widget.isFullscreen) {
      unawaited(VideoFullscreenOrientation.restore(isMobile: _isMobile));
    }
    _controller.disposePlayback();
    super.dispose();
  }

  void _toggleFullscreen() => widget.onFullscreenChanged(!widget.isFullscreen);

  Future<void> _applyOrientation({required bool fullscreen}) => fullscreen
      ? VideoFullscreenOrientation.enter()
      : VideoFullscreenOrientation.restore(isMobile: _isMobile);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
        height: VideoStageSizing.height(
          context: context,
          constraints: constraints,
          aspectRatio: _stageAspectRatio,
          isFullscreen: widget.isFullscreen,
        ),
        width: double.infinity,
        child: LessonVideoSurface(
          playback: _controller.playback,
          isPreparing: widget.isPreparing,
          onPrepare: widget.onPrepare,
          onRetry: () => unawaited(
            _controller.retry(
              url: widget.url,
              resumeSeconds: widget.resumeSeconds,
              mounted: mounted,
            ),
          ),
          seekLimitSeconds: widget.seekLimitSeconds,
          onSeek: (Duration target) =>
              unawaited(_controller.seekCorrection(target.inSeconds)),
          isFullscreen: widget.isFullscreen,
          onFullscreen: _toggleFullscreen,
          speed: widget.speed,
          onSpeedChanged: widget.onSpeedChanged,
          isLessonCompleted: widget.isLessonCompleted,
        ),
      ),
    );
  }
}
