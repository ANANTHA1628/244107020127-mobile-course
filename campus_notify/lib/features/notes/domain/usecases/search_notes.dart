import '../entities/note.dart';

/// Use case murni Dart untuk memfilter daftar catatan berdasarkan kata kunci pencarian.
/// Tidak memiliki dependensi pada Flutter SDK, Dio, atau SQLite (Clean Architecture).
class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(trimmedQuery);
      final bodyMatch = note.body.toLowerCase().contains(trimmedQuery);
      return titleMatch || bodyMatch;
    }).toList();
  }
}
