import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/api_endpoints.dart';
import '../routing/notification_destination.dart';
import 'dio_service.dart';
import 'notification_launcher.dart';

class PushNotificationService {
  PushNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Bilhikma Notifications',
    description: 'Used for important notifications while the app is open.',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _token;

  static String? get token => _token;

  static Future<void> ensureInitialized() async {
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint(
        'PushNotificationService: Firebase not configured yet: $error',
      );
      return;
    }

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission();
    debugPrint(
      'PushNotificationService: permission ${settings.authorizationStatus}',
    );

    _token = await FirebaseMessaging.instance.getToken();
    debugPrint('PushNotificationService: token $_token');

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _token = token;
      registerToken();
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);

    await _handleLaunchTap();
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
      debugPrint('PushNotificationService: token registration skipped: $error');
    }
  }

  /// A notification tap that started the app: the destination is queued and
  /// opened once the app has signed-in UI to navigate from.
  static Future<void> _handleLaunchTap() async {
    final RemoteMessage? initial = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initial != null) {
      _openFromMessage(initial);
      return;
    }

    final NotificationAppLaunchDetails? details = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _openFromPayload(details?.notificationResponse?.payload);
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
    debugPrint(
      'PushNotificationService: foreground message ${message.messageId}',
    );

    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

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
  }
}
