import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    final data = (response.data as List?) ?? [];
    return data
        .map((json) => Comment.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}