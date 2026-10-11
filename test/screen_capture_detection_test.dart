import 'package:bilhikma/core/enums/security_event_type_enum.dart';
import 'package:bilhikma/core/services/device_session_service.dart';
import 'package:bilhikma/core/services/screen_capture_service.dart';
import 'package:bilhikma/core/utils/cache_util.dart';
import 'package:bilhikma/features/security/data/models/security_event_model.dart';
import 'package:bilhikma/features/security/data/repos/security_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures what would have been POSTed to `/user/security-events`.
class _FakeSecurityRepo extends SecurityRepo {
  _FakeSecurityRepo(this.requests);

  final List<SecurityEventRequestModel> requests;

  @override
  Future<SecurityEventResponseModel> reportEvent(
    SecurityEventRequestModel request,
  ) async {
    requests.add(request);

    return const SecurityEventResponseModel(eventId: 1);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('bilhikma/screen_capture');
  const StandardMethodCodec codec = StandardMethodCodec();

  final List<SecurityEventRequestModel> requests =
      <SecurityEventRequestModel>[];

  late TestDefaultBinaryMessenger messenger;

  /// Delivers one event exactly as `ScreenCaptureDetector` emits it.
  Future<void> emit(Map<String, Object?> event) async {
    await messenger.handlePlatformMessage(
      channel.name,
      codec.encodeSuccessEnvelope(event),
      (_) {},
    );

    await pumpEventQueue();
  }

  setUpAll(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    // A report is only sent for a signed-in device.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'flutter.${DeviceSessionService.tokenKey}': 'test-token',
    });
    await CacheUtil.init();

    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    // The EventChannel sends `listen` before any event arrives.
    messenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async => null,
    );

    ScreenCaptureService.instance.attach(_FakeSecurityRepo(requests));
    ScreenCaptureService.instance.start();

    await pumpEventQueue();
  });

  tearDownAll(() async {
    await ScreenCaptureService.instance.stop();
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('a platform recording event reaches the security endpoint', () async {
    await emit(<String, Object?>{
      'type': 'screen_record',
      'active': true,
      'source': 'platform',
    });

    expect(requests, hasLength(1));
    expect(requests.single.eventType, SecurityEventType.screenRecord);
    expect(ScreenCaptureService.instance.isRecording, isTrue);

    // What the backend receives: the event type it already knows, plus the
    // detector that fired, so a 'display'-sourced report can be told from the
    // authoritative one.
    final Map<String, dynamic> json = requests.single.toJson();
    expect(json['event_type'], 'screen_record');
    expect((json['meta'] as Map<String, dynamic>)['source'], 'platform');
  });

  test('a second recording inside the debounce window is not resent', () async {
    requests.clear();

    await emit(<String, Object?>{
      'type': 'screen_record',
      'active': true,
      'source': 'display',
      'display_name': 'ScreenRecorder',
    });

    expect(requests, isEmpty);
  });

  test(
    'the recording state re-arms once the platform reports it stopped',
    () async {
      requests.clear();

      await emit(<String, Object?>{
        'type': 'screen_record',
        'active': false,
        'source': 'platform',
      });

      // Stopping is a state change, not an incident: nothing is reported.
      expect(requests, isEmpty);
      expect(ScreenCaptureService.instance.isRecording, isFalse);
    },
  );

  test('an external display is reported under its own event type', () async {
    requests.clear();

    await emit(<String, Object?>{
      'type': 'external_display',
      'active': true,
      'source': 'display',
      'display_name': 'HDMI',
      'secure': false,
    });

    expect(requests, hasLength(1));
    expect(requests.single.eventType, SecurityEventType.externalDisplay);

    final Map<String, dynamic> meta =
        requests.single.toJson()['meta'] as Map<String, dynamic>;
    expect(meta['source'], 'display');
    expect(meta['display'], 'HDMI');

    // An external display is not a recording.
    expect(ScreenCaptureService.instance.isRecording, isFalse);
  });

  test('an unknown event type is ignored', () async {
    requests.clear();

    await emit(<String, Object?>{'type': 'something_else', 'active': true});

    expect(requests, isEmpty);
  });
}
