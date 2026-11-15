import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';

void main() {
  testWidgets('menampilkan EmptyNotesView saat daftar catatan kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith((ref) => Future.value(<Note>[])),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);
    expect(find.byIcon(Icons.note_alt_outlined), findsOneWidget);
  });

  testWidgets(
    'menampilkan pesan tidak ada hasil saat query pencarian tidak cocok',
    (tester) async {
      final sampleNotes = [
        Note(
          id: 1,
          title: 'Tugas Kuliah',
          body: 'Kerjakan laporan minggu 9',
          updatedAt: DateTime(2026, 10, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesProvider.overrideWith((ref) => Future.value(sampleNotes)),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Catatan awal muncul
      expect(find.text('Tugas Kuliah'), findsOneWidget);

      // Ketik pencarian yang tidak ada di daftar
      await tester.enterText(find.byType(TextField), 'zzzzzz');
      await tester.pumpAndSettle();

      // Empty state pencarian muncul
      expect(
        find.text('Tidak ada catatan yang cocok dengan "zzzzzz".'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    },
  );
}
