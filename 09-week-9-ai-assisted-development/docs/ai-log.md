# AI Log — Minggu 9: AI-Assisted Development

**Nama Mahasiswa:** Muhammad Anantha Rezky  
**NIM:** 244107020127  
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** #09 — AI-Assisted Development / Vibe Coding  

---

## 1. Prompt Inti (Formula 5 Slot)

```text
Peran: senior Flutter dev
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
  Riverpod, GoRouter, SQLite + Dio.
  Folder: campus_notify/lib/features/notes/
  Entity Note memiliki field: id, title, body, updatedAt, dirty.
  Provider saat ini: notesProvider (FutureProvider<List<Note>>).
Tugas: Tambah fitur search/filter judul notes + empty state.
  - Buat use case SearchNotes di domain/usecases/ (pure Dart, tanpa import Flutter/Dio/SQLite).
  - Buat provider noteSearchQueryProvider (Notifier<String>) dan filteredNotesProvider.
  - Perbarui NotesPage dengan TextField pencarian dan empty state.
Batas: Jangan ubah arsitektur layer. Maks 80 baris per file.
  Jangan panggil SQLite dari widget. Domain bebas Flutter.
Output: Kode + 3 test case (sukses, gagal, edge case) + cara uji manual.
```

### Konteks yang Ditempel (Bukan Secret)

```dart
// domain/entities/note.dart
class Note {
  const Note({this.id, required this.title, this.body = '', required this.updatedAt, this.dirty = false});
  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
```

```dart
// presentation/providers/notes_providers.dart (sebelum modifikasi)
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});
```

```yaml
# pubspec.yaml (ringkasan dependensi)
flutter_riverpod: ^3.4.3
go_router: ^18.0.1
dio: ^5.11.1
sqflite: ^2.4.4+1
```

---

## 2. Output Awal AI

AI menghasilkan tiga file utama:

### File 1: `domain/usecases/search_notes.dart`
```dart
import '../entities/note.dart';

class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) return notes;

    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(trimmedQuery);
      final bodyMatch = note.body.toLowerCase().contains(trimmedQuery);
      return titleMatch || bodyMatch;
    }).toList();
  }
}
```

### File 2: Provider `noteSearchQueryProvider` + `filteredNotesProvider`
```dart
final noteSearchQueryProvider =
    NotifierProvider<NoteSearchNotifier, String>(NoteSearchNotifier.new);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(noteSearchQueryProvider);
  final searchUseCase = ref.watch(searchNotesUseCaseProvider);
  return notesAsync.whenData((notes) => searchUseCase(notes, query));
});
```

### File 3: UI `NotesPage` dengan search bar dan empty state
AI mengusulkan `ConsumerStatefulWidget` dengan `TextField` yang memanggil `ref.read(noteSearchQueryProvider.notifier).setQuery(value)` pada `onChanged`, serta widget `EmptyNotesView` yang menampilkan pesan berbeda antara "Belum ada catatan" dan "Tidak ada catatan yang cocok dengan query X".

---

## 3. Verifikasi 6 Langkah

### ✅ Langkah 1: Baca Tiap Baris
Seluruh kode AI dibaca baris per baris. Tidak ada baris yang tidak dipahami.

### ✅ Langkah 2: Cek Import (Sterilitas Layer)
```bash
grep -rn "package:flutter/" campus_notify/lib/features/notes/domain/
# Hasil: 0 kecocokan ✅ (Domain bebas Flutter)

grep -rn "package:dio/" campus_notify/lib/features/notes/domain/
# Hasil: 0 kecocokan ✅

grep -rn "package:sqflite/" campus_notify/lib/features/notes/domain/
# Hasil: 0 kecocokan ✅
```

### ✅ Langkah 3: Cek API
- `Notifier<String>` → ada di `flutter_riverpod ^3.4.3` ✅
- `NotifierProvider` → ada di `flutter_riverpod ^3.4.3` ✅
- `AsyncValue.whenData()` → ada di `flutter_riverpod` ✅
- `String.trim().toLowerCase().contains()` → Dart Core ✅

### ✅ Langkah 4: Flutter Analyze
```
flutter analyze → No issues found! (ran in 6.9s) ✅
```

### ✅ Langkah 5: Test Sukses & Gagal
```
flutter test → All 19 tests passed! ✅
```
- 9 unit test untuk `SearchNotes` use case (sukses, gagal, edge case)
- 2 widget test untuk `NotesPage` (empty state, search not found)
- 8 test existing (auth, FCM, get_notes)

### ✅ Langkah 6: Uji Manual
1. **Query kosong** → Seluruh catatan tampil ✅
2. **Query cocok** → Hanya catatan yang cocok tampil ✅
3. **Query tak cocok** → Empty state "Tidak ada catatan yang cocok dengan ..." tampil ✅

---

## 4. Halusinasi / Bug yang Ditemukan

### Bug 1: AI Menggunakan `note.content` yang Tidak Ada

**Observasi:** Pada output awal AI untuk `NotesList`, AI menggunakan `note.content` padahal entity `Note` hanya memiliki field `body`, bukan `content`.

**Bukti:**
```bash
grep -rn "note.content" campus_notify/lib/features/notes/
# Sebelum perbaikan: ditemukan di notes_page.dart baris 77
```

**Dampak:** Jika diterima mentah, kode akan error saat runtime/compile karena `Note` tidak memiliki property `content`.

**Perbaikan:** Diganti menjadi `note.body` pada seluruh widget.

### Bug 2: AI Menyarankan `controller.searchFuzzy()` (Method Fiktif)

**Observasi:** Pada prompt awal tentang search, AI sempat menyebutkan method `controller.searchFuzzy()` yang **tidak ada** di TextEditingController Flutter.

**Bukti:** Autocomplete IDE tidak menampilkan method tersebut. Tidak ditemukan di dokumentasi `pub.dev` untuk `TextEditingController`.

**Perbaikan:** Menggunakan `onChanged` callback standar pada `TextField` yang sudah terbukti ada.

---

## 5. Tabel Keputusan: Terima / Tolak Saran AI

| No | File/Kode AI | Keputusan | Alasan Teknis |
|:--:|:---|:---:|:---|
| 1 | `domain/usecases/search_notes.dart` | ✅ **TERIMA** | Pure Dart, tidak import framework, mudah diuji. Logic filter `contains()` case-insensitive benar. |
| 2 | `NoteSearchNotifier` (Notifier<String>) | ✅ **TERIMA** | Sesuai Riverpod 3.x API. State sederhana untuk query pencarian. |
| 3 | `filteredNotesProvider` (derived provider) | ✅ **TERIMA** | Reaktif menggunakan `whenData`, membiarkan use case murni menangani filter. |
| 4 | `NotesPage` dengan TextField search | ✅ **TERIMA + REFACTOR** | Diterima strukturnya, tapi `note.content` diganti `note.body`, dan ditambahkan `dispose()` untuk `TextEditingController`. |
| 5 | `EmptyNotesView` (empty state) | ✅ **TERIMA** | Membedakan antara "Belum ada catatan" vs "Tidak cocok dengan query" — UX yang baik. |
| 6 | `controller.searchFuzzy()` (method fiktif) | ❌ **DITOLAK** | **Halusinasi.** Method ini tidak ada di Flutter SDK. Diganti dengan `TextField.onChanged`. |
| 7 | Menyarankan import `package:flutter/material.dart` di use case | ❌ **DITOLAK** | Melanggar dependency rule Clean Architecture. Domain layer harus pure Dart. |

---

## 6. Refleksi

1. **Satu halusinasi AI yang ditemukan:**  
   AI menyebutkan `controller.searchFuzzy()` — method fiktif yang tidak ada di Flutter. Dibuktikan dengan cek autocomplete IDE dan pencarian di `pub.dev`. Tidak ada package mainstream yang menyediakan method ini pada `TextEditingController`.

2. **Prompt yang paling membantu:**  
   Prompt dengan formula 5 slot (Peran, Konteks, Tugas, Batas, Output) menghasilkan kode yang jauh lebih akurat karena AI tahu batasan arsitektur dan versi package. Tanpa batas, AI cenderung mencampur layer.

3. **Refactor yang dilakukan:**  
   Mengganti `note.content` menjadi `note.body` di seluruh widget, menambahkan `TextEditingController` dengan `dispose()` (menghindari memory leak), dan memindahkan logika filter dari widget ke use case domain murni.

4. **Keputusan terima/tolak yang paling sulit:**  
   Keputusan menolak `searchFuzzy()` karena pada pandangan pertama terlihat seperti API yang masuk akal, namun setelah verifikasi terbukti halusinasi. Ini menegaskan pentingnya langkah **Verify** sebelum menerima kode AI.
