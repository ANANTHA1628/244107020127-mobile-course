import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/post.dart';

class PostRepository {
  final Dio dio;
  final Database db;

  PostRepository(this.dio, this.db);

  Future<List<Post>> readCachedPosts() async {
    final List<Map<String, dynamic>> maps = await db.query('cached_posts');
    return maps.map((e) => Post.fromMap(e)).toList();
  }

  Future<void> savePostsToCache(List<Post> posts) async {
    final batch = db.batch();
    batch.delete('cached_posts');
    for (final post in posts) {
      batch.insert('cached_posts', post.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> refreshPostsInBackground({Function(List<Post>)? onRefreshed}) async {
    try {
      final res = await dio.get('https://jsonplaceholder.typicode.com/posts');
      if (res.statusCode == 200) {
        final List data = res.data;
        final freshPosts = data.map((json) => Post.fromJson(json)).toList();
        
        await savePostsToCache(freshPosts);
        
        if (onRefreshed != null) {
          onRefreshed(freshPosts);
        }
      }
    } catch (e) {
      // Abaikan error jaringan agar tidak mengganggu UI cache
    }
  }

  Future<List<Post>> loadPostsCacheFirst({Function(List<Post>)? onRefreshed}) async {
    final cached = await readCachedPosts();

    refreshPostsInBackground(onRefreshed: onRefreshed);
    
    return cached; 
  }
}