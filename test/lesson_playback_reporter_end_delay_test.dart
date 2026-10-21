import 'package:bilhikma/core/services/videoplayerservice/video_item.dart';
import 'package:bilhikma/core/services/videoplayerservice/video_playback.dart';
import 'package:bilhikma/features/lesson_detail/presentation/refactor/lesson_playback_reporter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal playback stand-in: the reporter only reads position/duration and
/// listens for changes, so nothing platform-bound is needed.
class _FakePlayback extends VideoPlayback {
  _FakePlayback() : super(VideoItem.fromUrl('https://e.test/a.mp4', id: 'x')!);

  Duration _position = Duration.zero;
  final Duration _duration = const Duration(seconds: 100);

  void emitPosition(Duration value) {
    _position = value;
    notifyListeners();
  }

  @override
  bool get isReady => true;
  @override
  bool get isPlaying => false;
  @override
  bool get isBuffering => false;
  @override
  bool get isLive => false;
  @override
  Duration get position => _position;
  @override
  Duration get duration => _duration;
  @override
  double get playbackSpeed => 1;
  @override
  double get reportedAspectRatio => 16 / 9;
  @override
  String? get errorMessage => null;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> seekTo(Duration target) async => emitPosition(target);
  @override
  Future<void> setPlaybackSpeed(double speed) async {}
  @override
  Widget buildSurface({Key? key, Widget? overlay}) => const SizedBox.shrink();
}

void main() {
  late _FakePlayback playback;
  late LessonPlaybackReporter reporter;
  late List<int> ended;

  setUp(() {
    ended = <int>[];
    playback = _FakePlayback();
    reporter = LessonPlaybackReporter(
      onTick: (_, _) {},
      onEnded: ended.add,
    );
    reporter.attach(playback);
  });

  tearDown(() {
    reporter.detach();
    playback.dispose();
  });

  testWidgets('end report is withheld for 1.5s, then fires once', (
    WidgetTester tester,
  ) async {
    playback.emitPosition(const Duration(seconds: 100));

    await tester.pump(const Duration(milliseconds: 1400));
    expect(ended, isEmpty, reason: 'must still be inside the grace period');

    await tester.pump(const Duration(milliseconds: 200));
    expect(ended, <int>[100]);

    // Further notifications must not produce a second report.
    playback.emitPosition(const Duration(seconds: 100));
    await tester.pump(const Duration(seconds: 10));
    expect(ended, <int>[100]);
  });

  testWidgets('detach during the grace period cancels the report', (
    WidgetTester tester,
  ) async {
    playback.emitPosition(const Duration(seconds: 100));

    await tester.pump(const Duration(milliseconds: 500));
    reporter.detach();

    await tester.pump(const Duration(seconds: 10));
    expect(ended, isEmpty, reason: 'leaving the screen withdraws the report');
  });

  testWidgets('seeking away during the grace period cancels the report', (
    WidgetTester tester,
  ) async {
    playback.emitPosition(const Duration(seconds: 100));

    await tester.pump(const Duration(milliseconds: 500));
    await reporter.seekTo(10);

    await tester.pump(const Duration(seconds: 10));
    expect(ended, isEmpty);

    // ...and reaching the end again re-arms it.
    playback.emitPosition(const Duration(seconds: 100));
    await tester.pump(const Duration(seconds: 2));
    expect(ended, <int>[100]);
  });
}
