import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';

class PagedPostPage extends ConsumerWidget {
  const PagedPostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pagedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts Paged (${state.items.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Load Next Page',
            onPressed: () {
              ref.read(pagedPostsProvider.notifier).loadNextPage();
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            ref.read(pagedPostsProvider.notifier).loadNextPage();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.items.length + 1,
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              if (!state.hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Semua data termuat.')),
                );
              }
              if (state.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox(height: 50);
            }

            final post = state.items[index];
            return ListTile(
              leading: CircleAvatar(child: Text(post.id.toString())),
              title: Text(post.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(post.body,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          },
        ),
      ),
    );
  }
}