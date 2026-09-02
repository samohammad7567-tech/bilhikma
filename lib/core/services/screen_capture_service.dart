import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../features/security/data/models/security_event_model.dart';
import '../../features/security/data/repos/security_repo.dart';
import 'device_session_service.dart';
import '../utils/cache_util.dart';
import '../enums/security_event_type_enum.dart';

class ScreenCaptureService {
  ScreenCaptureService._();

  static final ScreenCaptureService instance = ScreenCaptureService._();

  static const EventChannel _channel = EventChannel('bilhikma/screen_capture');

  static const Duration _debounce = Duration(seconds: 2);

  SecurityRepo _repo = const SecurityRepo();

  final StreamController<SecurityEventResponseModel> _reports =
      StreamController<SecurityEventResponseModel>.broadcast();

  StreamSubscription<dynamic>? _nativeSubscription;

  final List<_ScreenWatch> _watches = <_ScreenWatch>[];
  int _watchSeed = 0;
  bool _isRecording = false;
  bool _isListening = false;
  bool _isExempt = false;
  DateTime? _lastReportAt;
  SecurityEventType? _lastReportType;

  Stream<SecurityEventResponseModel> get reports => _reports.stream;

  bool get isRecording => _isRecording;

  bool get isExempt => _isExempt;

  /// Injects the repo once, at startup, so [ScreenCapturePolicy] can start and
  /// stop the listeners later without having to carry it around.
  void attach(SecurityRepo repo) => _repo = repo;

  /// The policy's decision, applied to the detectors: an exempt account is not
  /// listened to at all, so no capture of theirs can reach the backend. Not
  /// guarded on a change of value — the first call has to start the listeners
  /// even though it repeats the `false` this field starts life with.
  void applyExemption(bool isExempt) {
    _isExempt = isExempt;

    if (isExempt) {
      unawaited(stop());
      return;
    }

    start();
  }

  void start({SecurityRepo? repo}) {
    if (repo != null) _repo = repo;
    if (_isListening) return;

    _isListening = true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _nativeSubscription = _channel.receiveBroadcastStream().listen(
          _onNativeEvent,
          onError: (Object error) =>
              debugPrint('Screen capture channel failed: $error'),
        );
      case TargetPlatform.iOS:
        ScreenProtector.addListener(_onScreenshot, _onScreenRecord);
      case TargetPlatform():
        break;
    }
  }

  Future<void> stop() async {
    if (!_isListening) return;

    _isListening = false;

    await _nativeSubscription?.cancel();
    _nativeSubscription = null;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      ScreenProtector.removeListener();
    }
  }

  int pushScreen(String screen, {int? contentId}) {
    final int token = ++_watchSeed;

    _watches.add(
      _ScreenWatch(token: token, screen: screen, contentId: contentId),
    );

    return token;
  }

  void popScreen(int token) =>
      _watches.removeWhere((_ScreenWatch watch) => watch.token == token);

  _ScreenWatch? get _current => _watches.isEmpty ? null : _watches.last;

  Future<void> report(
    SecurityEventType eventType, {
    String? screen,
    int? contentId,
    Map<String, dynamic> meta = const <String, dynamic>{},
  }) async {
    // An exempt account never reaches the endpoint. The backend would file the
    // event without consequence, but an exemption means there is nothing to
    // report in the first place.
    if (_isExempt) return;

    final Object? token = CacheUtil.get(key: DeviceSessionService.tokenKey);
    if (token is! String || token.isEmpty) return;

    if (_isDuplicate(eventType)) return;

    final _ScreenWatch? watch = _current;

    try {
      final SecurityEventResponseModel response = await _repo.reportEvent(
        SecurityEventRequestModel(
          eventType: eventType,
          contentId: contentId ?? watch?.contentId,
          meta: <String, dynamic>{
            'screen': screen ?? watch?.screen ?? 'unknown',
            ...meta,
          },
        ),
      );

      if (!_reports.isClosed) _reports.add(response);
    } catch (error) {
      debugPrint('Security event report failed (${eventType.key}): $error');
    }
  }

  void _onNativeEvent(dynamic event) {
    if (event is! Map) return;

    final Map<String, dynamic> payload = Map<String, dynamic>.from(event);
    final SecurityEventType? eventType = _typeFromKey(payload['type']);
    if (eventType == null) return;

    if (payload['active'] != true) {
      if (eventType == SecurityEventType.screenRecord) _isRecording = false;
      return;
    }

    if (eventType == SecurityEventType.screenRecord) _isRecording = true;

    unawaited(
      report(
        eventType,
        meta: <String, dynamic>{
          if (payload['display_name'] != null)
            'display': payload['display_name'],
        },
      ),
    );
  }

  SecurityEventType? _typeFromKey(Object? key) {
    for (final SecurityEventType type in SecurityEventType.values) {
      if (type.key == key) return type;
    }
    return null;
  }

  void _onScreenshot() => unawaited(report(SecurityEventType.screenshot));

  void _onScreenRecord(bool isCaptured) {
    if (isCaptured == _isRecording) return;

    _isRecording = isCaptured;
    if (!isCaptured) return;

    unawaited(report(SecurityEventType.screenRecord));
  }

  bool _isDuplicate(SecurityEventType eventType) {
    if (eventType == SecurityEventType.screenshot) return false;

    final DateTime now = DateTime.now();
    final DateTime? last = _lastReportAt;

    if (_lastReportType == eventType &&
        last != null &&
        now.difference(last) < _debounce) {
      return true;
    }

    _lastReportAt = now;
    _lastReportType = eventType;
    return false;
  }
}

class _ScreenWatch {
  const _ScreenWatch({
    required this.token,
    required this.screen,
    this.contentId,
  });

  final int token;
  final String screen;
  final int? contentId;
}
