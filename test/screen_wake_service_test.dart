import 'package:bilhikma/core/services/screen_wake_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

class _FakeWakelock extends WakelockPlusPlatformInterface {
  final List<bool> calls = <bool>[];
  bool state = false;

  @override
  Future<void> toggle({required bool enable}) async {
    calls.add(enable);
    state = enable;
  }

  @override
  Future<bool> get enabled async => state;
}

void main() {
  late _FakeWakelock fake;

  setUp(() {
    fake = _FakeWakelock();
    // `WakelockPlus` captures its platform in a lazily-initialised top-level
    // var, so assigning `WakelockPlusPlatformInterface.instance` only lands
    // for whichever test runs first. Patch the var the facade actually reads.
    wakelockPlusPlatformInstance = fake;
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('holds the screen while an owner is playing and releases after', () async {
    final Object player = Object();

    ScreenWakeService.request(player, keepAwake: true);
    await settle();
    expect(fake.state, isTrue);

    ScreenWakeService.request(player, keepAwake: false);
    await settle();
    expect(fake.state, isFalse);
  });

  test('repeated identical ticks never reach the platform twice', () async {
    final Object player = Object();

    for (int i = 0; i < 20; i++) {
      ScreenWakeService.request(player, keepAwake: true);
    }
    await settle();

    expect(fake.calls, <bool>[true]);

    ScreenWakeService.release(player);
    await settle();
    expect(fake.calls, <bool>[true, false]);
  });

  test('stays held until the last of several players stops', () async {
    final Object video = Object();
    final Object audio = Object();

    ScreenWakeService.request(video, keepAwake: true);
    ScreenWakeService.request(audio, keepAwake: true);
    await settle();
    expect(fake.state, isTrue);

    // One player paused; the other is still playing.
    ScreenWakeService.release(video);
    await settle();
    expect(fake.state, isTrue, reason: 'audio is still playing');

    ScreenWakeService.release(audio);
    await settle();
    expect(fake.state, isFalse);
  });

  tearDown(() async {
    // Leave the service clean for the next test.
    await settle();
  });
}
