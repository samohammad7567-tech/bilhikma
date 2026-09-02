import 'dart:async';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';

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

    if (enablePictureInPicture) {
      unawaited(
        _floating
            .enable(const OnLeavePiP())
            .catchError((_) => PiPStatus.unavailable),
      );
    }

    await playback.initialize();
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
