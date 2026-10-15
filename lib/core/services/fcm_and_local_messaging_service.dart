import 'dart:async';
import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notification pop-ups.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint(
      'Handling background message: ${message.messageId}, '
      'title: ${message.notification?.title}, body: ${message.notification?.body}, '
      'data: ${message.data}',
    );
  }

  final data = Map<String, dynamic>.from(message.data);
  final type = data['type']?.toString();
  if (type != 'notice' &&
      type != 'resource' &&
      type != 'routine' &&
      type != 'exam') {
    return;
  }

  final localPlugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();

  await localPlugin.initialize(
    settings: const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
  );

  await localPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_channel);

  final title =
      data['title']?.toString() ?? message.notification?.title ?? 'CR Assist';
  final body =
      data['body']?.toString() ??
      message.notification?.body ??
      'You have a new update';

  final localPayload = <String, dynamic>{
    ...data,
    '_messageKey': message.messageId ?? message.hashCode.toString(),
  };

  await localPlugin.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'CR Assist',
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(localPayload),
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  factory NotificationService() => instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  final Set<String> _handledMessageKeys = <String>{};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _setupLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    final token = await _fcm.getToken();
    if (kDebugMode) print('FCM Device Token: $token');

    _setupForegroundListener();
    _openedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );
    _initialized = true;

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleRemoteMessage(initialMessage);
      });
    }

    final launchDetails = await _localPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _handleData(Map<String, dynamic>.from(jsonDecode(payload) as Map));
          } catch (error) {
            debugPrint('Failed to handle launch notification payload: $error');
          }
        });
      }
    }
  }

  Future<AuthorizationStatus> permissionStatus() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus;
  }

  Future<bool> requestPermissionOrOpenSettings() async {
    final currentStatus = await permissionStatus();

    if (currentStatus == AuthorizationStatus.notDetermined) {
      final status = await requestPermission();
      return status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;
    }

    if (currentStatus == AuthorizationStatus.authorized ||
        currentStatus == AuthorizationStatus.provisional) {
      return true;
    }

    if (currentStatus == AuthorizationStatus.denied &&
        defaultTargetPlatform == TargetPlatform.android) {
      try {
        await const AndroidIntent(
          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
          arguments: <String, dynamic>{
            'android.provider.extra.APP_PACKAGE': 'com.example.cr_assist',
          },
        ).launch();
        return true;
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Notification settings intent failed: $error');
        }
        try {
          await const AndroidIntent(
            action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
            data: 'package:com.example.cr_assist',
          ).launch();
          return true;
        } catch (fallbackError) {
          if (kDebugMode) {
            debugPrint('App settings intent failed: $fallbackError');
          }
          return false;
        }
      }
    }

    if (currentStatus == AuthorizationStatus.denied) {
      return launchUrl(
        Uri.parse('app-settings:'),
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _localPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          _handleData(Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } catch (error) {
          debugPrint('Invalid local notification payload: $error');
        }
      },
    );

    await _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  void _setupForegroundListener() {
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final data = Map<String, dynamic>.from(message.data);

      if (kDebugMode) {
        debugPrint(
          'Foreground FCM message: ${message.messageId}, '
          'title: ${notification?.title}, body: ${notification?.body}, '
          'data: ${message.data}',
        );
      }

      if (data['type'] != 'notice' &&
          data['type'] != 'resource' &&
          data['type'] != 'routine' &&
          data['type'] != 'exam') {
        return;
      }

      final localPayload = <String, dynamic>{
        ...data,
        '_messageKey': message.messageId ?? message.hashCode.toString(),
      };
      final title =
          data['title']?.toString() ?? notification?.title ?? 'CR Assist';
      final body =
          data['body']?.toString() ??
          notification?.body ??
          'You have a new update';
      _localPlugin.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: 'CR Assist',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(localPayload),
      );
    });
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    _handleData(message.data, messageKey: message.messageId);
  }

  void _handleData(Map<String, dynamic> data, {String? messageKey}) {
    final key =
        messageKey ?? data['_messageKey']?.toString() ?? jsonEncode(data);
    if (!_handledMessageKeys.add(key)) return;

    final type = data['type']?.toString();
    final route = data['route']?.toString();

    if (type == 'notice' && route == 'notices') {
      AppRouter.go('/notice');
      return;
    }

    if ((type == 'routine' || type == 'exam') &&
        (route == null || route == 'routine')) {
      AppRouter.go('/routine');
      return;
    }

    if (type == 'resource' && route == 'subject-resources') {
      final subjectId = int.tryParse(data['subjectId']?.toString() ?? '');
      if (subjectId == null || subjectId <= 0) {
        debugPrint('Resource notification ignored: missing subjectId');
        return;
      }

      AppRouter.go(
        '/resources',
        extra: {
          'subjectId': subjectId,
          'subjectName': data['subjectName']?.toString() ?? 'Resources',
        },
      );
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    _foregroundSubscription = null;
    _openedAppSubscription = null;
    _initialized = false;
  }
}
