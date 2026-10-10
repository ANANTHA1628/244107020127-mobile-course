import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes {
  final NoteRepository repository;

  const GetNotes(this.repository);

  Future<({List<Note> notes, Failure? failure})> call() async {
    return await repository.fetchNotes();
  }
}