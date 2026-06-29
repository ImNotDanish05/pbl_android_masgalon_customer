import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────
// NotificationService — Customer App
//
// Tanggung jawab:
//   1. Init Firebase Messaging & minta permission notifikasi
//   2. Ambil FCM token perangkat (untuk diupload ke Supabase)
//   3. Tampilkan local notification saat app foreground (via flutter_local_notifications)
//   4. Handle tap notifikasi → navigasi ke halaman terkait
//
// Cara pakai:
//   Panggil NotificationService.init(navigatorKey) di main() sebelum runApp()
// ─────────────────────────────────────────────────────────────

// Handler background message — HARUS top-level function (bukan method class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final _messaging = FirebaseMessaging.instance;

  // Local notification plugin untuk tampilkan notif saat foreground
  static final _localNotif = FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const _androidChannel = AndroidNotificationChannel(
    'masgalon_high_importance', // channel id
    'Masgalon Notifikasi', // channel name
    description: 'Notifikasi pesanan, top-up, dan pesan dari Mas Galon.',
    importance: Importance.high,
  );

  // ── Init: panggil sekali di main() ──────────────────────────
  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // 1. Daftarkan background handler (sebelum apapun)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission (Android 13+ dan iOS butuh ini)
    if (Platform.isAndroid || Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 3. Setup flutter_local_notifications
    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload, navigatorKey);
      },
    );

    // 4. Buat Android channel
    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    // 5. Handle foreground message → tampilkan local notification
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM-Customer] Menerima pesan foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 6. Handle tap notifikasi saat app di background (tapi tidak terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM-Customer] Aplikasi dibuka dari notifikasi background');
      _handleRemoteMessageTap(message, navigatorKey);
    });

    // 7. Handle tap notifikasi saat app terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM-Customer] Aplikasi diluncurkan dari notifikasi terminated');
      // Delay singkat agar Navigator sudah siap
      await Future.delayed(const Duration(milliseconds: 500));
      _handleRemoteMessageTap(initialMessage, navigatorKey);
    }

    debugPrint('[FCM-Customer] NotificationService initialized.');
  }

  // ── Ambil token FCM perangkat ini ───────────────────────────
  static Future<String?> getToken() async {
    try {
      await requestPermission();
      final token = await _messaging.getToken();
      debugPrint('[FCM-Customer] Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      debugPrint('[FCM-Customer] Gagal ambil token: $e');
      return null;
    }
  }

  // ── Minta izin notifikasi ────────────────────────────────────
  static Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('[FCM-Customer] Gagal meminta izin notifikasi: $e');
    }
  }

  // ── Tampilkan local notification (saat foreground) ──────────
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        debugPrint('[FCM-Customer] Tidak menampilkan local notification: payload notification kosong.');
        return;
      }

      final payload = message.data.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      debugPrint('[FCM-Customer] Menampilkan local notification: ${notification.title}');
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
      debugPrint('[FCM-Customer] Local notification berhasil ditampilkan.');
    } catch (e) {
      debugPrint('[FCM-Customer] Exception saat menampilkan local notification: $e');
    }
  }

  // ── Handle tap dari local notification ──────────────────────
  static void _handleNotificationTap(
    String? payload,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (payload == null) return;
    final params = Uri.splitQueryString(payload);
    _navigate(params, navigatorKey);
  }

  // ── Handle tap dari remote message (background/terminated) ──
  static void _handleRemoteMessageTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    _navigate(message.data, navigatorKey);
  }

  // ── Routing berdasarkan data payload ────────────────────────
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
