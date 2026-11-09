import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/features/optimized_list.dart';
import '../lib/repository/item_repository.dart';

class FakeDataSource implements ItemDataSource {
  int callCount = 0;
  List<Item> mockData = [
    const Item(id: 1, title: 'Item 1', description: 'Desc 1'),
    const Item(id: 2, title: 'Item 2', description: 'Desc 2'),
  ];

  @override
  Future<List<Item>> fetchFromNetwork() async {
    callCount++;
    return mockData;
  }
}

void main() {
  group('ItemRepository - Stale-While-Revalidate Caching Tests', () {
    test('Mengembalikan data segar dan menyimpan ke cache lokal', () async {
      final fake = FakeDataSource();
      final repo = ItemRepository(remoteDataSource: fake);

      final items = await repo.getItems();
      expect(items.length, equals(2));
      expect(repo.currentCache.length, equals(2));
      expect(fake.callCount, equals(1));
    });

    test('Memancarkan cache segera sebelum network fetch selesai', () async {
      final fake = FakeDataSource();
      final repo = ItemRepository(remoteDataSource: fake);

      // Isi cache awal
      await repo.getItems();

      // Panggilan kedua: stream harus memancarkan data cache
      final emissions = <List<Item>>[];
      final sub = repo.itemStream.listen(emissions.add);

      await repo.getItems();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emissions.isNotEmpty, isTrue);
      expect(emissions.first.length, equals(2));

      await sub.cancel();
      repo.dispose();
    });
  });

  group('OptimizedListPage - Widget Rendering Tests', () {
    testWidgets('Merender daftar dengan ListView.builder dan ItemTile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OptimizedListPage(),
        ),
      );

      // Tunggu load page selesai
      await tester.pumpAndSettle();

      expect(find.text('Daftar Teroptimasi (Week 11)'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ItemTile), findsWidgets);
      expect(find.text('Item Perkuliahan #1'), findsOneWidget);
    });

    testWidgets('Lazy loading menambah item saat di-scroll ke bawah', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OptimizedListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll ke bawah untuk memicu pagination
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.byType(ItemTile), findsWidgets);
    });
  });
}
