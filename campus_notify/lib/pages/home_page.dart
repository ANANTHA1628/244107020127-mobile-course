import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kampus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Status: Berhasil Login',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/pengumuman/101'),
              child: const Text('Buka Pengumuman #101'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/debug'),
              child: const Text('Buka Halaman Debug FCM'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/notes'),
              child: const Text('Buka Catatan (Notes)'),
            ),
          ],
        ),
      ),
    );
  }
}