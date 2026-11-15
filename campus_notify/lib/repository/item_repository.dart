import 'dart:async';

class Item {
  final int id;
  final String title;
  final String description;

  const Item({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };
}

abstract class ItemDataSource {
  Future<List<Item>> fetchFromNetwork();
}

/// Repository dengan strategi Caching Stale-While-Revalidate
class ItemRepository {
  ItemRepository({required this.remoteDataSource});

  final ItemDataSource remoteDataSource;
  final List<Item> _memoryCache = [];

  // Stream controller untuk memancarkan pembaruan data secara reaktif
  final _controller = StreamController<List<Item>>.broadcast();
  Stream<List<Item>> get itemStream => _controller.stream;

  List<Item> get currentCache => List.unmodifiable(_memoryCache);

  /// Pola Stale-While-Revalidate:
  /// 1. Sajikan cache lokal segera jika ada.
  /// 2. Ambil data baru di latar belakang.
  /// 3. Perbarui cache dan pancarkan data terbaru.
  Future<List<Item>> getItems() async {
    // 1. Sajikan cache segera
    if (_memoryCache.isNotEmpty) {
      _controller.add(List.unmodifiable(_memoryCache));
    }

    try {
      // 2. Fetch fresh data di background
      final fresh = await remoteDataSource.fetchFromNetwork();

      // 3. Update cache
      _memoryCache
        ..clear()
        ..addAll(fresh);

      // 4. Emit fresh data
      _controller.add(List.unmodifiable(_memoryCache));
      return fresh;
    } catch (e) {
      // Jika jaringan gagal dan cache tersedia, jadikan cache sebagai fallback aman
      if (_memoryCache.isNotEmpty) {
        return _memoryCache;
      }
      rethrow;
    }
  }

  void dispose() {
    _controller.close();
  }
}
