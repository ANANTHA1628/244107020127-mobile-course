import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../models/post.dart';
import 'repositories/notes_repositories.dart';

class SyncService {
  final NoteRepository noteRepository;
  final Dio dio;
  final Future<Database> Function() openDb;

  SyncService({
    required this.noteRepository,
    required this.dio,
    required this.openDb,
  });

  Future<int> syncNotes() async {
    final dirtyCount = await noteRepository.countDirty();
    if (dirtyCount == 0) return 0;

    await Future.delayed(const Duration(seconds: 1));
    await noteRepository.markAllSynced();
    return dirtyCount;
  }

  Future<List<Post>> loadPostsCacheFirst({Function(List<Post>)? onRefreshed}) async {
    final db = await openDb();

    final List<Map<String, dynamic>> maps = await db.query('cached_posts');
    final cached = maps.map((e) => Post.fromMap(e)).toList();

    _refreshPostsInBackground(openDb, onRefreshed);

    return cached;
  }

  Future<void> _refreshPostsInBackground(
    Future<Database> Function() openDb,
    Function(List<Post>)? onRefreshed,
  ) async {
    try {
      final res = await dio.get('https://jsonplaceholder.typicode.com/posts');
      if (res.statusCode == 200) {
        final List data = res.data;
        final freshPosts = data.map((json) => Post.fromJson(json)).toList();

        final db = await openDb();
        final batch = db.batch();
        batch.delete('cached_posts');
        for (final post in freshPosts) {
          batch.insert('cached_posts', post.toMap());
        }
        await batch.commit(noResult: true);

        if (onRefreshed != null) {
          onRefreshed(freshPosts);
        }
      }
    } catch (_) {
      // Abaikan error jaringan background
    }
  }
}