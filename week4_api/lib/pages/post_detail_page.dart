import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';

final postDetailProvider =
    FutureProvider.family<Post, int>((ref, id) async {
  // Cek apakah item sudah termuat di list pagination
  final pagedItems = ref.watch(pagedPostsProvider).items;
  final cached = pagedItems.where((p) => p.id == id);
  if (cached.isNotEmpty) {
    return cached.first;
  }

  // Cek di list non-paged
  final listAsync = ref.watch(postListProvider);
  if (listAsync.hasValue) {
    final listCached = listAsync.value!.where((p) => p.id == id);
    if (listCached.isNotEmpty) return listCached.first;
  }

  // Jika tidak ada di state lokal, ambil dari API
  return ref.watch(postRepositoryProvider).fetchPostById(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Post #$id')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
          ),
        ),
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                post.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}