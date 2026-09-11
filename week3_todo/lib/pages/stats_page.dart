import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatItem {
  final String title;
  final String value;
  const StatItem({required this.title, required this.value});
}

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    return _fetchStats();
  }

  Future<List<StatItem>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextDouble() < 0.3) {
      throw Exception('Gagal memuat statistik (30% failure rate).');
    }
    return const [
      StatItem(title: 'Total Pengguna', value: '1.240'),
      StatItem(title: 'Transaksi Aktif', value: '85'),
      StatItem(title: 'Tingkat Konversi', value: '4.8%'),
    ];
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik AI')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(error.toString().replaceAll('Exception: ', '')),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(statsProvider.notifier).retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (stats) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: stats.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) => ListTile(
            title: Text(stats[i].title),
            trailing: Text(
              stats[i].value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}