import 'package:flutter/material.dart';
import '../data/local/note.dart';
import '../data/repositories/notes_repositories.dart';

class NoteDetailPage extends StatelessWidget {
  final int noteId;
  final NoteRepository repository;

  const NoteDetailPage({
    super.key,
    required this.noteId,
    required this.repository,
  });

  Future<Note?> _loadNote() async {
    final notes = await repository.fetchNotes();
    try {
      return notes.firstWhere((n) => n.id == noteId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: FutureBuilder<Note?>(
        future: _loadNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final note = snapshot.data;
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt.toLocal()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                Text(
                  note.body.isNotEmpty ? note.body : '(Tidak ada isi)',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}