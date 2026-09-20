import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson Unit Tests', () {
    test('Mengembalikan objek default yang aman saat field hilang atau bernilai null', () {
      final Map<String, dynamic> emptyJson = {};

      final comment = Comment.fromJson(emptyJson);

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('Edge Case: Tetap dapat melakukan parsing jika id berupa String angka', () {
      final Map<String, dynamic> rawJson = {
        'postId': '10',
        'id': '105',
        'name': 'Budi',
        'email': null,
      };

      final comment = Comment.fromJson(rawJson);

      expect(comment.postId, 10);
      expect(comment.id, 105);
      expect(comment.name, 'Budi');
      expect(comment.email, '');
      expect(comment.body, '');
    });
  });
}