# AI Review vs. Keputusan Final (Minggu 8)

**Nama Mahasiswa:** Muhammad Anantha Rezky  
**NIM:** 244107020127  
**Modul:** #08 - Mid Project Review & Code Review  

---

## 1. AI Prompt Challenge

Prompt yang dikirimkan ke AI Coding Assistant untuk mengevaluasi Pull Request fitur validasi catatan dan integrasi arsitektur:

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Output Awal AI Reviewer

Berikut adalah respons 5 temuan yang diberikan oleh AI Coding Assistant:

### Temuan 1 (Level: Blocker - Kebenaran & Validasi)
* **Observasi:** Method penyimpanan catatan baru hanya mengecek string kosong (`title.isEmpty`), namun input yang hanya berisi karakter spasi (`"   "`) tetap lolos dan tersimpan ke SQLite sebagai record tidak valid.
* **Dampak:** Data kotor (empty whitespaces) tersimpan di database lokal dan terkirim saat background sync ke REST API backend, memicu 400 Bad Request.
* **Usulan Kode Perbaikan:**
  ```dart
  if (title.trim().isEmpty) {
    throw ValidationFailure('Judul catatan tidak boleh kosong');
  }
  ```

### Temuan 2 (Level: Blocker - Arsitektur / Dependency Rule)
* **Observasi:** Pada `NoteRepositoryImpl`, ada import `package:flutter/material.dart` dan pemanggilan `ScaffoldMessenger.of(context).showSnackBar(...)` langsung dari blok `catch` repository saat sinkronisasi gagal.
* **Dampak:** Layer data menjadi bergantung secara langsung pada framework UI Flutter (`BuildContext`). Hal ini merusak prinsip Clean Architecture dan membuat layer data tidak dapat diuji secara headless unit test.
* **Usulan Kode Perbaikan:**
  Kembalikan failure objek `Left(ServerFailure(message))` atau lempar custom exception, biarkan presentation layer (Notifier / UI) yang menangani rendering SnackBar.
  ```dart
  // Di NoteRepositoryImpl:
  catch (e) {
    throw Failure.server('Gagal sinkronisasi catatan: $e');
  }
  ```

### Temuan 3 (Level: Saran - Ketahanan Error & Offline Path)
* **Observasi:** Saat terjadi timeout jaringan pada `DioClient`, status catatan lokal tidak dipertahankan status `dirty = 1`, sehingga data yang belum tersinkron tidak akan dicoba kembali pada interval sync berikutnya.
* **Dampak:** Catatan baru tidak tersinkronisasi selamanya jika sync pertama gagal karena koneksi lambat/putus.
* **Usulan Kode Perbaikan:**
  ```dart
  // Pastikan flag dirty tetap 1 pada database lokal jika status sync gagal
  await db.update('notes', {'dirty': 1}, where: 'id = ?', whereArgs: [note.id]);
  ```

### Temuan 4 (Level: Blocker - Cakupan Test)
* **Observasi:** Test `get_notes_test.dart` hanya menguji kondisi sukses (`Right(List<Note>)`), tetapi skenario ketika database SQLite gagal dibuka atau melempar exception belum diuji.
* **Dampak:** Regresi pada error handling tidak akan terdeteksi di CI pipeline.
* **Usulan Kode Perbaikan:**
  ```dart
  test('harus mengembalikan Failure ketika repository melempar DatabaseException', () async {
    when(() => mockRepo.getNotes()).thenAnswer((_) async => Left(DatabaseFailure('DB Lock')));
    final result = await useCase();
    expect(result, isA<Left>());
  });
  ```

### Temuan 5 (Level: Blocker / Saran Arsitektur - Penolakan)
* **Observasi:** AI mengusulkan untuk menambahkan parameter `BuildContext context` ke method execute Use Case `AddNoteUseCase` agar use case bisa langsung menavigasi pengguna kembali ke halaman daftar catatan (`context.pop()`) setelah simpan sukses.
* **Dampak Usulan:** Menginjeksi `BuildContext` ke dalam Domain Layer melanggar prinsip Dependency Rule Clean Architecture secara total. Domain layer wajib murni Dart Core.

---

## 3. AI Verification Checklist & Tabel Keputusan Final

| No | Temuan AI | Level yang Diklaim | Status Verifikasi | Keputusan Final | Bukti & Argumen Teknis |
| :-: | :--- | :---: | :---: | :---: | :--- |
| **1** | Input string whitespace `"   "` tidak tervalidasi | Blocker | **VALID & TERBUKTI** | **DITERIMA** | Dilakukan pengujian input `'   '` dan terbukti record tersimpan dengan title kosong ke SQLite. Solusi `title.trim().isEmpty` diterapkan di usecase validasi. |
| **2** | UI ScaffoldMessenger dipanggil di dalam repository data | Blocker | **VALID & TERBUKTI** | **DITERIMA** | Grep menemukan import `flutter/material.dart` di layer data. Seluruh logika UI dihapus dari repository; error dikembalikan sebagai failure entity. |
| **3** | Catatan gagal sync harus tetap bertanda `dirty = 1` | Saran | **VALID & TERBUKTI** | **DITERIMA** | Menjaga konsistensi strategi offline-first. Record tetap ditandai dirty sampai response HTTP 200/201 diterima. |
| **4** | Kurangnya test kasus kegagalan repository | Blocker | **VALID & TERBUKTI** | **DITERIMA** | Ditambahkan unit test baru di `test/` yang memverifikasi propagation `DatabaseFailure` dan `NetworkFailure`. |
| **5** | Mengoper `BuildContext` ke `AddNoteUseCase` untuk auto-pop | Blocker | **TIDAK VALID (SALAH)** | **DITOLAK KERAS** | **Alasan Penolakan:** Saran AI secara terang-terangan melanggar prinsip fundamental Clean Architecture. Domain layer sama sekali tidak boleh mengenal UI atau `BuildContext`. Navigasi `context.pop()` adalah tanggung jawab penuh presentation page / widget controller. |

---

## 4. Kesimpulan Evaluasi AI Reviewer

AI sangat efektif dan teliti dalam mendeteksi:
1. Edge case data input (seperti karakter whitespace kosong).
2. Skenario pengujian unit test yang kurang lengkap.
3. Potensi kebocoran dependensi framework.

Namun, pengembang manusia tetap memegang kendali mutlak dalam arsitektur karena AI sering kali menawarkan solusi "jalan pintas" (seperti mengoper `BuildContext` ke layer domain) yang berpotensi merusak arsitektur jangka panjang.
