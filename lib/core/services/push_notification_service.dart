import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/api_endpoints.dart';
import '../routing/notification_destination.dart';
import '../utils/app_logger.dart';
import 'dio_service.dart';
import 'notification_launcher.dart';

/// Push notifications, set up so that nothing here can stop the app.
///
/// Every call below depends on Google Play services, the network, or both.
/// Neither is guaranteed: an older phone may carry a Play services build too
/// old to mint a token, a de-Googled ROM has none at all, and a slow or
/// captive network makes `getToken()` take tens of seconds before failing with
/// `SERVICE_NOT_AVAILABLE`. Push is a feature, not a precondition for the app
/// running, so each stage is guarded and time-boxed and the whole thing is
/// started *after* the first frame.
class PushNotificationService {
  PushNotificationService._();

  static const String _logName = 'push';

  /// Talking to Play services and then to Google. Generous, because this now
  /// runs behind a live UI where a slow answer costs the user nothing.
  static const Duration _remoteTimeout = Duration(seconds: 20);

  /// Platform-local work: channel creation, reading the launch intent.
  static const Duration _localTimeout = Duration(seconds: 8);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Bilhikma Notifications',
    description: 'Used for important notifications while the app is open.',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _hasStarted = false;
  static bool _isReady = false;
  static String? _token;

  static String? get token => _token;

  /// True when messaging is wired up and a token was obtained. False means the
  /// app is running without push — a normal state, not an error.
  static bool get isReady => _isReady;

  /// Sets up messaging. Safe to call more than once; only the first call does
  /// work. Never throws, so it is safe to leave unawaited.
  static Future<void> ensureInitialized() async {
    if (_hasStarted) return;
    _hasStarted = true;

    if (!await _initializeFirebase()) return;

    await _initializeLocalNotifications();
    await _requestPermission();

    // Listeners go up before the token is fetched: the fetch can take twenty
    // seconds, and a message arriving in that window should still be handled.
    _attachMessageListeners();

    await _resolveToken();
    await _handleLaunchTap();

    _isReady = _token != null && _token!.isNotEmpty;
    AppLogger.info(
      _isReady
          ? 'Push notifications ready'
          : 'Push notifications unavailable on this device',
      name: _logName,
    );
  }

  /// Returns false when Firebase cannot start — a missing or malformed
  /// `google-services.json`, or Play services too old to host it. Everything
  /// downstream is pointless in that case.
  static Future<bool> _initializeFirebase() async {
    try {
      await Firebase.initializeApp().timeout(_remoteTimeout);
      return true;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Firebase could not start; push notifications are off',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      await _localNotifications
          .initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            ),
            onDidReceiveNotificationResponse: _onLocalNotificationTap,
          )
          .timeout(_localTimeout);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel)
          .timeout(_localTimeout);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Local notification channel unavailable; '
        'foreground notifications will not be shown',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _requestPermission() async {
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission()
          .timeout(_remoteTimeout);

      AppLogger.info(
        'Notification permission: ${settings.authorizationStatus.name}',
        name: _logName,
      );
    } catch (error) {
      AppLogger.warning(
        'Notification permission could not be requested',
        name: _logName,
        error: error,
      );
    }
  }

  static void _attachMessageListeners() {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (String token) {
          _token = token;
          _isReady = token.isNotEmpty;
          unawaited(registerToken());
        },
        onError: (Object error) => AppLogger.warning(
          'Token refresh stream failed',
          name: _logName,
          error: error,
        ),
      );

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Could not attach message listeners',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// The single most failure-prone call in the app on older hardware: it needs
  /// a current Play services and a reachable Google endpoint, and reports
  /// neither problem quickly.
  static Future<void> _resolveToken() async {
    try {
      _token = await FirebaseMessaging.instance.getToken().timeout(
        _remoteTimeout,
      );
    } catch (error) {
      // SERVICE_NOT_AVAILABLE, MISSING_INSTANCEID_SERVICE, a timeout on a bad
      // link — all mean the same thing here, and none of them is fatal.
      AppLogger.warning(
        'FCM token unavailable; continuing without push',
        name: _logName,
        error: error,
      );
      return;
    }

    await registerToken();
  }

  static Future<void> registerToken() async {
    final String? token = _token;
    if (token == null || token.isEmpty) return;

    final Object? authorization =
        DioService.dio?.options.headers['Authorization'];
    if (authorization is! String || authorization.trim() == 'Bearer') return;

    try {
      await DioService.post(
        ApiEndpoints.deviceFcmToken,
        data: <String, dynamic>{'fcm_token': token},
      );
    } catch (error) {
      AppLogger.warning(
        'Token registration skipped',
        name: _logName,
        error: error,
      );
    }
  }

  /// A notification tap that started the app: the destination is queued and
  /// opened once the app has signed-in UI to navigate from.
  static Future<void> _handleLaunchTap() async {
    try {
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(_localTimeout);

      if (initial != null) {
        _openFromMessage(initial);
        return;
      }

      final NotificationAppLaunchDetails? details = await _localNotifications
          .getNotificationAppLaunchDetails()
          .timeout(_localTimeout);

      if (details?.didNotificationLaunchApp ?? false) {
        _openFromPayload(details?.notificationResponse?.payload);
      }
    } catch (error) {
      AppLogger.warning(
        'Could not read the launch notification',
        name: _logName,
        error: error,
      );
    }
  }

  static void _openFromMessage(RemoteMessage message) => NotificationLauncher
      .instance
      .open(NotificationDestination.fromPushData(message.data));

  static void _onLocalNotificationTap(NotificationResponse response) =>
      _openFromPayload(response.payload);

  static void _openFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      NotificationLauncher.instance.open(null);
      return;
    }

    try {
      final Object? decoded = jsonDecode(payload);

      NotificationLauncher.instance.open(
        decoded is Map
            ? NotificationDestination.fromPushData(
                Map<String, dynamic>.from(decoded),
              )
            : null,
      );
    } on FormatException {
      NotificationLauncher.instance.open(null);
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    try {
      await _localNotifications.show(
        id: message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error) {
      AppLogger.warning(
        'Could not show the foreground notification '
        '${message.messageId ?? '<no id>'}',
        name: _logName,
        error: error,
      );
    }
  }
}
