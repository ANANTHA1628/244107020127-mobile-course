import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/search_notes.dart';

void main() {
  late SearchNotes searchNotes;
  late List<Note> sampleNotes;

  setUp(() {
    searchNotes = const SearchNotes();
    sampleNotes = [
      Note(
        id: 1,
        title: 'Belanja Bulanan',
        body: 'Beli beras, telur, dan sayur',
        updatedAt: DateTime(2026, 10, 1),
      ),
      Note(
        id: 2,
        title: 'Tugas Flutter',
        body: 'Kerjakan codelab minggu 9 tentang search',
        updatedAt: DateTime(2026, 10, 2),
      ),
      Note(
        id: 3,
        title: 'Meeting Proyek',
        body: 'Diskusi arsitektur clean architecture',
        updatedAt: DateTime(2026, 10, 3),
      ),
      Note(
        id: 4,
        title: 'Belanja Elektronik',
        body: 'Cari harga charger laptop',
        updatedAt: DateTime(2026, 10, 4),
      ),
    ];
  });

  group('SearchNotes Use Case', () {
    test('query kosong mengembalikan seluruh catatan', () {
      final result = searchNotes(sampleNotes, '');
      expect(result, hasLength(4));
      expect(result, equals(sampleNotes));
    });

    test('query whitespace saja mengembalikan seluruh catatan', () {
      final result = searchNotes(sampleNotes, '   ');
      expect(result, hasLength(4));
    });

    test('filter berdasarkan judul (case-insensitive)', () {
      final result = searchNotes(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result[0].title, 'Belanja Bulanan');
      expect(result[1].title, 'Belanja Elektronik');
    });

    test('filter berdasarkan isi body', () {
      final result = searchNotes(sampleNotes, 'arsitektur');
      expect(result, hasLength(1));
      expect(result.first.title, 'Meeting Proyek');
    });

    test('filter abaikan huruf besar/kecil', () {
      final result = searchNotes(sampleNotes, 'FLUTTER');
      expect(result, hasLength(1));
      expect(result.first.title, 'Tugas Flutter');
    });

    test('query tak cocok mengembalikan daftar kosong', () {
      final result = searchNotes(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    test('query cocok sebagian kata di body', () {
      final result = searchNotes(sampleNotes, 'charger');
      expect(result, hasLength(1));
      expect(result.first.title, 'Belanja Elektronik');
    });

    test('filter daftar kosong mengembalikan kosong', () {
      final result = searchNotes([], 'apapun');
      expect(result, isEmpty);
    });

    test('query dengan spasi di awal/akhir tetap cocok', () {
      final result = searchNotes(sampleNotes, '  belanja  ');
      expect(result, hasLength(2));
    });
  });
}
