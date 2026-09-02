import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';
import '../../../../core/utils/orientation/orientation_util.dart';
import '../../../../core/utils/screen_size.dart';
import '../refactor/lesson_playback_reporter.dart';
import 'lesson_video_controls.dart';

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

  @override
  State<LessonVideoStage> createState() => _LessonVideoStageState();
}

class _LessonVideoStageState extends State<LessonVideoStage> {
  late final LessonPlaybackReporter _reporter = LessonPlaybackReporter(
    onTick: (int position, int played) => widget.onTick(position, played),
    onEnded: (int duration) => widget.onEnded(duration),
  );

  VideoPlayback? _playback;
  bool _isMobile = true;

  @override
  void initState() {
    super.initState();
    unawaited(_createIfPossible());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _isMobile = ScreenSize.isMobile(context);
  }

  @override
  void didUpdateWidget(LessonVideoStage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFullscreen != widget.isFullscreen) {
      unawaited(_applyOrientation(fullscreen: widget.isFullscreen));
    }

    if (oldWidget.url != widget.url) {
      _teardown();
      unawaited(_createIfPossible());
      return;
    }

    final int? correction = widget.correctionSeconds;
    if (correction != null &&
        oldWidget.correctionRevision != widget.correctionRevision) {
      unawaited(_reporter.seekTo(correction));
    }
  }

  @override
  void dispose() {
    if (widget.isFullscreen) unawaited(_restoreOrientation());

    _teardown();
    super.dispose();
  }

  Future<void> _createIfPossible() async {
    final String? url = widget.url;
    if (url == null || url.isEmpty) return;

    final VideoItem? item = VideoItem.fromUrl(url, id: 'lesson-video');
    if (item == null) return;

    final VideoPlayback playback = VideoPlayback.forItem(item);
    _playback = playback;
    _reporter.attach(playback);

    await playback.initialize();
    if (!mounted) return;

    await _reporter.resumeAt(widget.resumeSeconds);
  }

  void _teardown() {
    _reporter.detach();
    _playback?.dispose();
    _playback = null;
  }

  void _toggleFullscreen() => widget.onFullscreenChanged(!widget.isFullscreen);

  Future<void> _applyOrientation({required bool fullscreen}) async {
    if (!fullscreen) return _restoreOrientation();

    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations(
      getPreferredOrientationsByDeviceType(_isMobile),
    );
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayback? playback = _playback;

    final double height = widget.isFullscreen
        ? double.infinity
        : MediaQuery.sizeOf(context).width / (16 / 10);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: Colors.black,
        child: playback == null
            ? _Placeholder(
                isPreparing: widget.isPreparing,
                onTap: widget.onPrepare,
              )
            : ListenableBuilder(
                listenable: playback,
                builder: (BuildContext context, _) => playback.buildSurface(
                  overlay: LessonVideoControls(
                    isPlaying: playback.isPlaying,
                    isBuffering: playback.isBuffering,
                    isFullscreen: widget.isFullscreen,
                    position: playback.position,
                    duration: playback.duration,
                    maxPosition: Duration(seconds: widget.seekLimitSeconds),
                    onToggle: playback.togglePlayPause,
                    onRewind: () =>
                        playback.seekBy(const Duration(seconds: -10)),
                    onSeek: (Duration target) =>
                        _reporter.seekTo(target.inSeconds),
                    onFullscreen: _toggleFullscreen,
                  ),
                ),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isPreparing, required this.onTap});

  final bool isPreparing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isPreparing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: _RoundButton(icon: Icons.play_arrow, onTap: onTap),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 56.w,
          height: 56.w,
          child: Icon(icon, size: 30.w, color: Colors.white),
        ),
      ),
    );
  }
}
