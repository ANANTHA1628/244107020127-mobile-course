import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
    },
  );
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await onToken(token);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

String maskToken(String? token) {
  if (token == null || token.isEmpty) return 'Menunggu token...';
  if (token.length <= 12) return '$token...';
  return '${token.substring(0, 12)}...';
}