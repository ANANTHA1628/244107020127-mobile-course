import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

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

Future<void> initLocalNotifications(void Function(String route) go) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        go(route);
      }
    },
  );

  const channel = AndroidNotificationChannel(
    'pengumuman',
    'Pengumuman Kampus',
    description: 'Channel untuk notifikasi pengumuman kampus',
    importance: Importance.high,
  );

  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Fungsi lifecycle token untuk Praktikum 2
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

// Fungsi masking token agar aman saat difoto/screenshot laporan
String maskToken(String? token) {
  if (token == null || token.isEmpty) return 'Menunggu token...';
  if (token.length <= 12) return '$token...';
  return '${token.substring(0, 12)}...';
}

void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman Baru',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'];
    if (route != null && route.isNotEmpty) {
      go(route);
    }
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = initial.data['route'];
    if (route != null && route.isNotEmpty) {
      go(route);
      return;
    }
  }

  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

Future<void> subscribeCampusTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

Future<void> unsubscribeCampusTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
}