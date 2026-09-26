import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/notes_repositories.dart';
import 'settings_page.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final NoteRepository _repo = NoteRepository();
  List<Note> _notes = [];
  int _dirtyCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final dirty = await _repo.countDirty();
    final allNotes = await _repo.fetchNotes();
    setState(() {
      _dirtyCount = dirty;
      _notes = allNotes;
    });
  }

  Future<void> _addNote() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Judul catatan...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(hintText: 'Isi catatan...'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await _repo.addNote(
                  title: titleController.text.trim(),
                  body: bodyController.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  _refreshData();
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSync() async {
    // 1. Cek mode force-offline
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal sinkronisasi: Mode force-offline aktif!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Jalankan sync jika online
    setState(() => _isLoading = true);
    final synced = await _repo.syncNotes();
    setState(() => _isLoading = false);

    await _refreshData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil menyinkronkan $synced catatan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          // Badge indikator dirty
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _dirtyCount > 0 ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Dirty: $_dirtyCount',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              _refreshData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('Belum ada catatan. Tekan tombol + untuk menambah.'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        '${note.body.isNotEmpty ? "${note.body}\n" : ""}${note.updatedAt.toLocal()}',
                      ),
                      trailing: note.dirty
                          ? const Tooltip(
                              message: 'Belum tersinkron (Dirty)',
                              child: Icon(Icons.cloud_off, color: Colors.orange),
                            )
                          : const Tooltip(
                              message: 'Tersinkron',
                              child: Icon(Icons.cloud_done, color: Colors.green),
                            ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'sync_action',
            onPressed: _handleSync,
            tooltip: 'Sinkronisasi Catatan',
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add_action',
            onPressed: _addNote,
            tooltip: 'Tambah Catatan Baru',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}