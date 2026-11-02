import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/entities/note.dart';
import '../../data/datasources/notes_db.dart';

// Data layer: database opener disuntikkan (mudah diganti fake saat test)
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima abstraksi, bukan implementasi
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// Use case pencarian catatan (pure Dart)
final searchNotesUseCaseProvider = Provider<SearchNotes>((ref) {
  return const SearchNotes();
});

// State notifier untuk query pencarian catatan
class NoteSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final noteSearchQueryProvider = NotifierProvider<NoteSearchNotifier, String>(
  NoteSearchNotifier.new,
);

// Presentation layer: state untuk UI daftar catatan mentah
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});

// Presentation layer: state catatan terfilter berdasarkan kata kunci pencarian
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(noteSearchQueryProvider);
  final searchUseCase = ref.watch(searchNotesUseCaseProvider);

  return notesAsync.whenData((notes) => searchUseCase(notes, query));
});
