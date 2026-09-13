import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'dart:async';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint(
      'Handling background message: ${message.messageId}, '
      'title: ${message.notification?.title}, body: ${message.notification?.body}',
    );
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notification pop-ups.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint(
          'FCM notification permission not authorized: '
          '${settings.authorizationStatus}',
        );
      }
    }

    // 2. Setup Local Notifications & Android Channel
    await _setupLocalNotifications();

    // 3. Set Background Handler & iOS Options
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Print FCM Token
    String? token = await _fcm.getToken();
    if (kDebugMode) print("FCM Device Token: $token");

    // 5. Setup Listeners
    _setupForegroundListener();
    await _setupInteractedMessage();
    _initialized = true;
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localPlugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        if (kDebugMode) print('Local notification tapped payload: ${response.payload}');
      },
    );

    await _localPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _setupForegroundListener() {
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (kDebugMode) {
        debugPrint(
          'Foreground FCM message: ${message.messageId}, '
          'from: ${message.from}, title: ${notification?.title}, '
          'body: ${notification?.body}, data: ${message.data}',
        );
      }

      if (notification != null) {
        _localPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  Future<void> _setupInteractedMessage() async {
    // Terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage);
    }

    // Background state
    _openedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
  }

  void _handleNavigation(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        'Notification clicked: ${message.messageId}, data: ${message.data}',
      );
    }
    AppRouter.go('/notice');
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    _foregroundSubscription = null;
    _openedAppSubscription = null;
    _initialized = false;
  }
}