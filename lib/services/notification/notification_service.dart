import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../supabase_client.dart';
import 'fcm_token_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  debugPrint(
    '[FCM-Customer] Background message: ${message.messageId} '
    'title=${message.notification?.title} data=${message.data}',
  );
}

class NotificationService {
  NotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'masgalon_high_importance',
    'Masgalon Notifikasi',
    description: 'Notifikasi pesanan, top-up, dan pesan dari Mas Galon.',
    importance: Importance.high,
  );

  static bool _initialized = false;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) {
      debugPrint('[FCM-Customer] NotificationService already initialized.');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _messaging.setAutoInitEnabled(true);

    if (Platform.isAndroid || Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        '[FCM-Customer] Permission status: ${settings.authorizationStatus}',
      );
    }

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload, navigatorKey);
      },
    );

    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '[FCM-Customer] Foreground message: '
        'title=${message.notification?.title} body=${message.notification?.body} '
        'data=${message.data}',
      );
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM-Customer] App opened from background notification.');
      _handleRemoteMessageTap(message, navigatorKey);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint(
        '[FCM-Customer] Token refreshed: ${token.substring(0, 20)}...',
      );
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await FcmTokenService.uploadToken(userId, token);
      } else {
        debugPrint('[FCM-Customer] Token refresh skipped: no logged in user.');
      }
    });

    final startupToken = await _messaging.getToken();
    debugPrint(
      '[FCM-Customer] Startup token: '
      '${startupToken == null ? 'null' : '${startupToken.substring(0, 20)}...'}',
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM-Customer] App launched from terminated notification.');
      await Future.delayed(const Duration(milliseconds: 500));
      _handleRemoteMessageTap(initialMessage, navigatorKey);
    }

    _initialized = true;
    debugPrint('[FCM-Customer] NotificationService initialized.');
  }

  static Future<String?> getToken() async {
    try {
      await requestPermission();
      await _messaging.setAutoInitEnabled(true);
      final token = await _messaging.getToken();
      debugPrint(
        '[FCM-Customer] Token: '
        '${token == null ? 'null' : '${token.substring(0, 20)}...'}',
      );
      return token;
    } catch (e) {
      debugPrint('[FCM-Customer] Gagal ambil token: $e');
      return null;
    }
  }

  static Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint(
          '[FCM-Customer] requestPermission result: ${settings.authorizationStatus}',
        );
      }
    } catch (e) {
      debugPrint('[FCM-Customer] Gagal meminta izin notifikasi: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        debugPrint(
          '[FCM-Customer] Skip local notification: notification payload kosong. '
          'data=${message.data}',
        );
        return;
      }

      final payload = message.data.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      debugPrint(
        '[FCM-Customer] Show local notification: ${notification.title}',
      );
      await _localNotif.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint(
        '[FCM-Customer] Exception saat menampilkan local notification: $e',
      );
    }
  }

  static void _handleNotificationTap(
    String? payload,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (payload == null) return;
    final params = Uri.splitQueryString(payload);
    _navigate(params, navigatorKey);
  }

  static void _handleRemoteMessageTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    _navigate(message.data, navigatorKey);
  }

  static void _navigate(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final type = data['type']?.toString();
    if (type == 'order') {
      final orderId = data['order_id']?.toString();
      if (orderId != null) {
        Navigator.of(context).pushNamed('/order-detail', arguments: orderId);
      }
    } else if (type == 'topup') {
      Navigator.of(context).pushNamed('/topup');
    }
  }
}
