import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/debug_token_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);
  ref.listen<AsyncValue<bool>>(authStateProvider, (_, next) {
    authNotifier.value = next.value ?? false;
  });

  return GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugTokenPage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
    );
  }
}