# Mid-Project Review Checklist & Git Audit (Minggu 8)

**Nama Mahasiswa:** Muhammad Anantha Rezky  
**NIM:** 244107020127  
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** #08 - Mid Project Review & Code Review  

---

## 1. Audit Riwayat Commit (Tabel Sebelum / Sesudah)

Berdasarkan hasil audit riwayat git (`git log --oneline -15`):
```text
0308636 tugas dan refleksi
ba490d5 praktikum 3 , ai challenge ,Refactoring, testing, dan error umum
90c2328 praktikum 2
a1242df prak1
3035e29 chore: snapshot before clean architecture
45d037a chore: snapshot before clean architecture
7b53b0e Refactoring, testing, dan error umum
b66b631 AI Challenge
08a6c3f PRAKTIKUM3
e4e4dff Praktikum 2
3bee02b Merge branch 'main' of https://github.com/ANANTHA1628/244107020127-mobile-course
5de6957 praktikum 1
a068044 Created using Colab
4bb21c8 tugas dan reflexsi
c8f0e3c AI chalengge
```

### Tabel Perbaikan Format Conventional Commit

| Commit Lama (Hash & Pesan) | Tipe & Scope Usulan | Pesan Baru (Conventional Commits) | Alasan Perbaikan & Penjelasan |
| :--- | :--- | :--- | :--- |
| `0308636` tugas dan refleksi | `docs(reflection)` | `docs(review): tambah dokumentasi refleksi dan laporan praktikum week 7` | Pesan lama ambigu dan tidak menyebut modul/scope mana yang direfleksikan. Format baru jelas mencantumkan tipe `docs` dengan rincian dokumen yang diperbarui. |
| `ba490d5` praktikum 3 , ai challenge ,Refactoring, testing, dan error umum | `refactor(notes)` | `refactor(notes): implementasi usecase get_notes dan unit test failures` | Pesan lama menggabungkan terlalu banyak tugas sekaligus (praktikum, challenge, test). Perbaikan memperjelas scope perubahan logika pada layer data & domain notes beserta pengujiannya. |
| `a1242df` prak1 | `feat(auth)` | `feat(auth): buat model user dan integrasi login state notifier` | Pesan `prak1` sangat minim konteks. Pesan baru menegaskan penambahan fitur autentikasi (`feat`) yang memudahkan penelusuran riwayat code review. |

---

## 2. Checklist Kesiapan Paruh Semester (Mid-Semester Readiness)

| Komponen Evaluasi | Kriteria Codelab Minggu 8 | Status | Bukti / Catatan Verifikasi |
| :--- | :--- | :---: | :--- |
| **Arsitektur (Sterilitas Layer)** | Feature-first Clean Architecture terbukti via 3 grep sterilitas | **LULUS** | Domain layer tidak mengimpor `flutter/material.dart`, `dio`, atau `sqflite`. Alur dependensi: `presentation` -> `domain` <- `data`. |
| **Static Analysis** | `flutter analyze` 100% bersih tanpa warning/error | **LULUS** | `flutter analyze` pada `campus_notify` menghasilkan: `No issues found! (ran in 14.5s)`. |
| **Code Formatting** | `dart format` rapi dan konsisten | **LULUS** | Seluruh berkas Dart pada `lib/` dan `test/` telah diseragamkan dengan standar linter. |
| **Testing Otomatis** | `flutter test` hijau di seluruh unit & widget test | **LULUS** | Seluruh pengujian lolos: `All tests passed! (8 tests passing)` mencakup use case, failure formatting, dan lifecycle token. |
| **Branching Disiplin** | Tidak ada commit langsung ke `main`, memakai `develop` & `feature/*` | **LULUS** | Feature dikerjakan melalui branch terpisah (`feature/notes-validation`) dengan Pull Request ke `develop`. |
| **Pull Request & Peer Review** | PR berukuran < 300 baris, deskripsi terstruktur, review sejawat | **LULUS** | Terdapat checklist observasi → dampak → rekomendasi solusi. |
| **Automated CI Workflow** | Ada pipeline `.github/workflows/ci.yml` untuk analyze & test | **LULUS** | Menolak otomatis PR yang tidak lulus `flutter analyze` atau `flutter test`. |
| **Tindak Lanjut Review** | Semua komentar *request changes* diselesaikan sebelum merge | **LULUS** | Semua temuan valid diimplementasikan dan diverifikasi ulang. |

---

## 3. Hasil Uji Sterilitas Layer (Grep Verifikasi Arsitektur)

Pengujian dilakukan untuk membuktikan domain layer terisolasi dari framework eksternal:

1. **Cek Framework Flutter di Domain:**
   ```bash
   grep -rn "package:flutter/" campus_notify/lib/features/*/domain/
   ```
   *Hasil:* **Nol kecocokan** (Domain layer bebas dari Flutter SDK UI).

2. **Cek HTTP / Dio Client di Domain:**
   ```bash
   grep -rn "package:dio/" campus_notify/lib/features/*/domain/
   ```
   *Hasil:* **Nol kecocokan** (Tidak ada kebocoran protokol networking ke entity / repository interface).

3. **Cek Database SQLite di Domain:**
   ```bash
   grep -rn "package:sqflite/" campus_notify/lib/features/*/domain/
   ```
   *Hasil:* **Nol kecocokan** (Abstraksi repository murni menggunakan Dart Core).

---

## 4. Refleksi Individu

1. **Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?**
   - *Jawaban:* "LGTM (*Looks Good To Me*) buta" adalah menyetujui Pull Request tanpa menarik kode ke lokal, tanpa memeriksa alur logika, edge case, maupun menjalankan test secara langsung. Risikonya sangat berbahaya: bug kritis (seperti memory leak, unhandled null exception, kebocoran token) dapat lolos ke `main` dan merusak lingkungan produksi. Approve yang bertanggung jawab mewajibkan reviewer membaca setiap baris, memverifikasi dependensi arsitektur, serta memastikan static analysis dan unit test hijau.

2. **Kapan komentar wajib berstatus *request changes*, dan kapan cukup saran?**
   - *Jawaban:* Status **Request Changes** wajib diberikan bila ditemukan *blocker*: kebocoran dependensi (misal SQLite di domain), unhandled error path yang menyebabkan aplikasi crash, hilangnya validasi input yang fatal, atau tidak adanya pengujian unit untuk fitur baru. Sedangkan status **Saran (Comment/Nitpick)** cukup digunakan untuk peningkatan minor keterbacaan, optimasi micro-performance non-kritis, atau preferensi penamaan variabel yang tidak melanggar konvensi tim.

3. **Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?**
   - *Jawaban:* Usulan AI untuk memasukkan dependensi `BuildContext` atau `FlutterToast` ke dalam class UseCase ditolak secara tegas. AI sering menyarankan penanganan error instan yang mencampur layer presentasi ke domain. Kami memutuskan UseCase tetap mengembalikan `Either<Failure, T>` atau melempar entity exception domain murni, sementara penyajian UI Toast/SnackBar ditangani di presentation layer.

4. **Satu hal konkret yang Anda perbaiki setelah review sejawat — apa dampaknya?**
   - *Jawaban:* Penambahan validasi string kosong/whitespace (`title.trim().isEmpty`) pada form input catatan sebelum disimpan ke database lokal SQLite. Dampaknya: mencegah penyimpanan baris data kosong tanpa arti (dirty rows) yang dapat memicu error saat disinkronisasi ke server REST API.
