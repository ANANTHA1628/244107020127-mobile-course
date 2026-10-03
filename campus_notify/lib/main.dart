import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_token_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart'; 

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);
  ref.listen<AsyncValue<bool>>(authStateProvider, (_, next) {
    authNotifier.value = next.value ?? false;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.root;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.debug,
        builder: (context, state) => const DebugTokenPage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  registerBackgroundHandler();

  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    // 3. Jalankan setup setelah frame pertama selesai agar router siap menerima navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPushNotifications();
    });
  }

  Future<void> _setupPushNotifications() async {
    await requestNotificationPermission();

    void navigateTo(String route) {
      final router = ref.read(routerProvider);
      router.push(route);
    }

    await initLocalNotifications(navigateTo);
    listenForeground(navigateTo);
    await handleTerminated(navigateTo); 
    await subscribeCampusTopic();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
    );
  }
}