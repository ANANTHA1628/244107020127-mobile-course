import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentRepository(dio);
});

class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout (10 detik tercapai). Coba lagi nanti.';
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Periksa jaringan internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data komentar tidak ditemukan (404).';
        if (code == 500) return 'Terjadi gangguan internal pada server (500).';
        return 'Server merespon dengan status $code.';
      default:
        return 'Terjadi gangguan jaringan saat memuat komentar.';
    }
  }
  return 'Terjadi kesalahan sistem: $error';
}