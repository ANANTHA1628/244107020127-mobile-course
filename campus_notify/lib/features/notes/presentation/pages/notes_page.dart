import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredState = ref.watch(filteredNotesProvider);
    final currentQuery = ref.watch(noteSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kampus'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan berdasarkan judul atau isi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteSearchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                ref.read(noteSearchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          Expanded(
            child: filteredState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return EmptyNotesView(query: currentQuery);
                }
                return NotesList(notes: notes);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Empty State
class EmptyNotesView extends StatelessWidget {
  final String query;

  const EmptyNotesView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final isSearching = query.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Tidak ada catatan yang cocok dengan "$query".'
                  : 'Belum ada catatan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget ErrorView
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Terjadi kesalahan: $message', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget NotesList
class NotesList extends StatelessWidget {
  final List<Note> notes;

  const NotesList({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.note),
          ),
          title: Text(note.title),
          subtitle: Text(
            note.body.isNotEmpty ? note.body : '(Tanpa isi)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
