import 'dart:async';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';

import '../../utils/app_logger.dart';
import '../device_info_service.dart';
import 'video_item.dart';
import 'video_playback.dart';

class FloatingVideoController extends ChangeNotifier {
  FloatingVideoController({this.enablePictureInPicture = true});

  final bool enablePictureInPicture;

  final Floating _floating = Floating();

  VideoPlayback? _playback;
  bool _isExpanded = false;
  Offset? _pipOffset;
  Size _pipSize = const Size(150, 86);
  GlobalKey? _playerKey;

  VideoPlayback? get playback => _playback;
  VideoItem? get item => _playback?.item;
  bool get isExpanded => _isExpanded;
  Offset? get pipOffset => _pipOffset;
  Size get pipSize => _pipSize;

  GlobalKey? get playerKey => _playerKey;

  bool get hasVideo => _playback != null;

  Future<void> open(VideoItem item) async {
    if (item.source.isEmpty) return;

    _disposePlayback();

    final VideoPlayback playback = VideoPlayback.forItem(item);

    _playback = playback;
    _isExpanded = true;
    _pipOffset = null;
    _playerKey = GlobalKey();
    notifyListeners();

    unawaited(_enablePictureInPicture());

    await playback.initialize();
  }

  /// Asks for Picture-in-Picture, but only where the platform can grant it.
  ///
  /// Two independent gates, because the failure is not recoverable in Dart:
  /// `enterPictureInPictureMode()` on an activity that cannot host PiP throws
  /// `IllegalStateException` on the Android main thread, which takes the
  /// process down rather than completing this future with an error. The
  /// `.catchError` that used to wrap it could never have caught that.
  ///
  /// [DeviceInfoService.supportsPictureInPicture] rules out API < 26, where
  /// PiP does not exist at all; [Floating.isPipAvailable] then asks the
  /// platform whether this particular device and user allow it.
  Future<void> _enablePictureInPicture() async {
    if (!enablePictureInPicture) return;
    if (!DeviceInfoService.supportsPictureInPicture) return;

    try {
      if (!await _floating.isPipAvailable) return;

      await _floating.enable(const OnLeavePiP());
    } catch (error) {
      AppLogger.warning(
        'Picture-in-Picture refused by the platform',
        name: 'video',
        error: error,
      );
    }
  }

  Future<void> retry() async {
    final VideoItem? current = item;
    if (current == null) return;

    await open(current);
  }

  void minimize() {
    if (!hasVideo || !_isExpanded) return;
    _isExpanded = false;
    notifyListeners();
  }

  void expand() {
    if (!hasVideo || _isExpanded) return;
    _isExpanded = true;
    notifyListeners();
  }

  void closeVideo() {
    _disposePlayback();
    _isExpanded = false;
    _pipOffset = null;
    _pipSize = const Size(150, 86);
    _playerKey = null;
    notifyListeners();

    if (enablePictureInPicture) {
      unawaited(_floating.cancelOnLeavePiP().catchError((_) {}));
    }
  }

  void updatePipOffset(Offset offset) {
    _pipOffset = offset;
    notifyListeners();
  }

  void updatePipSize(Size size) {
    _pipSize = size;
    notifyListeners();
  }

  void _disposePlayback() {
    _playback?.dispose();
    _playback = null;
  }

  @override
  void dispose() {
    _disposePlayback();

    if (enablePictureInPicture) {
      unawaited(_floating.cancelOnLeavePiP().catchError((_) {}));
    }

    super.dispose();
  }
}
