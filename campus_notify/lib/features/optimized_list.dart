import 'package:flutter/material.dart';
import '../../repository/item_repository.dart';

/// Halaman List Teroptimasi dengan:
/// 1. ListView.builder (Lazy Loading viewport saja)
/// 2. const Constructor pada Widget Statis
/// 3. Widget Terpisah (ItemTile) untuk meminimalkan scope rebuild
/// 4. RepaintBoundary untuk mengisolasi area repaint
/// 5. Pagination / Infinite Scroll
class OptimizedListPage extends StatefulWidget {
  const OptimizedListPage({super.key, this.repository});

  final ItemRepository? repository;

  @override
  State<OptimizedListPage> createState() => _OptimizedListPageState();
}

class _OptimizedListPageState extends State<OptimizedListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Item> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Simulasi lazy loading & pagination
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    if (_page > 3) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    final newItems = List.generate(
      15,
      (index) => Item(
        id: (_page - 1) * 15 + index + 1,
        title: 'Item Perkuliahan #${(_page - 1) * 15 + index + 1}',
        description: 'Deskripsi modul dan materi pertemuan ke-$_page',
      ),
    );

    setState(() {
      _items.addAll(newItems);
      _page++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Teroptimasi (Week 11)'),
      ),
      body: RepaintBoundary(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _items.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ItemTile(item: _items[index]);
          },
        ),
      ),
    );
  }
}

/// Widget ItemTile diekstrak ke class terpisah dengan `const` constructor
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${item.id}'),
      ),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
