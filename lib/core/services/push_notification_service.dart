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
import 'push_event_bus.dart';

class PushNotificationService {
  PushNotificationService._();

  static const String _logName = 'push';
  static const Duration _remoteTimeout = Duration(seconds: 20);
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
  static bool get isReady => _isReady;
  static Future<void> ensureInitialized() async {
    if (_hasStarted) return;
    _hasStarted = true;

    if (!await _initializeFirebase()) return;

    await _initializeLocalNotifications();
    await _requestPermission();
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

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
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

  static Future<void> _resolveToken() async {
    try {
      _token = await FirebaseMessaging.instance.getToken().timeout(
        _remoteTimeout,
      );
    } catch (error) {
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

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    PushEventBus.instance.emit(message.data);

    await _showForegroundNotification(message);
  }

  static void _openFromMessage(RemoteMessage message) {
    PushEventBus.instance.emit(message.data);

    NotificationLauncher.instance.open(
      NotificationDestination.fromPushData(message.data),
    );
  }

  static void _onLocalNotificationTap(NotificationResponse response) =>
      _openFromPayload(response.payload);

  static void _openFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      NotificationLauncher.instance.open(null);
      return;
    }

    try {
      final Object? decoded = jsonDecode(payload);
      if (decoded is! Map) {
        NotificationLauncher.instance.open(null);
        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
      PushEventBus.instance.emit(data);

      NotificationLauncher.instance.open(
        NotificationDestination.fromPushData(data),
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
