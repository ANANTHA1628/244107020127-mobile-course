import 'package:flutter_test/flutter_test.dart';

bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}

void main() {
  group('isValidTaskTitle', () {
    test('menerima judul yang berisi teks', () {
      expect(isValidTaskTitle('Belajar Flutter'), isTrue);
    });

    test('menolak teks kosong', () {
      expect(isValidTaskTitle(''), isFalse);
    });

    test('menolak teks yang hanya berisi spasi', () {
      expect(isValidTaskTitle('   '), isFalse);
    });

    test('menerima judul dengan spasi di awal/akhir', () {
      expect(isValidTaskTitle('  Tugas Kuliah  '), isTrue);
    });
  });
}
