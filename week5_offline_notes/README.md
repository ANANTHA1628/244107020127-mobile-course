## Aturan Konflik Sinkronisasi (Conflict Resolution)

Mekanisme yang digunakan adalah **Last-Write-Wins (LWW)** berbasis metadata `updated_at`:
1. Setiap entri lokal maupun server mencatat timestamp UTC saat data dibuat/dimodifikasi.
2. Ketika sinkronisasi dua arah dijalankan:
   - Data lokal dengan nilai `updated_at` yang lebih baru akan menimpa data di server.
   - Jika versi server memiliki timestamp yang lebih baru atau setara, data lokal digantikan oleh versi server dan flag `dirty` di-reset ke `0`.
3. Pendekatan ini mencegah penimpaan data secara diam-diam (*silent overwrite*) tanpa memerlukan antarmuka penyelesaian konflik manual yang rumit bagi pengguna.

AI VERIVICATION

Apakah AI menempatkan daftar catatan di SharedPreferences?

Temuan: Ditolak. SharedPreferences hanya dialokasikan untuk preferensi tema dan pengaturan. SharedPreferences tidak dirancang untuk menangani koleksi dinamis catatan yang membutuhkan indexing dan query agregasi.

Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?

Temuan: Skema dilengkapi dengan kolom dirty INTEGER (antrean sync) dan updated_at TEXT (timestamp UTC untuk resolusi konflik Last-Write-Wins), serta ditambahkan index idx_notes_dirty untuk optimasi 1.000+ data.

Apakah klaim "real-time" AI didukung stream atau hanya asumsi?

Temuan: Pada sqflite, pembaruan UI dilakukan secara manual melalui notifikasi state Riverpod (_refreshData()). Reaktivitas stream native hanya didukung bila menggunakan Drift (watch()) atau Hive (ValueListenable).

Apakah estimasi boilerplate AI masuk akal setelah instalasi nyata?

Temuan: Ya. sqflite hanya memerlukan penambahan package di pubspec.yaml dan pembuatan database helper tanpa memerlukan generator kode tambahan (build_runner).


keputusan Final

Kombinasi Terpilih: SharedPreferences + sqflite.

Alasan:

SharedPreferences menangani preferensi pengguna non-relasional yang dibaca cepat saat aplikasi dibuka.

sqflite menangani data transaksional catatan dengan dukungan antrean sync (dirty = 1), eksekusi indeks performa tinggi, dan minim dependensi build tooling tambahan.


1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?
Penyebab Teknis: SharedPreferences berbasis file XML (Android) / Plist (iOS) yang menyimpan pasangan key-value. Untuk menyimpan daftar catatan, seluruh koleksi harus di-serialize menjadi satu string JSON besar.

Dampak Kerusakan:

Kinerja & Memori: Setiap kali menambah atau membaca 1 catatan saja, seluruh berkas XML/JSON harus di-parse ulang ke memori (I/O blocking). Pada volume data besar (ratusan/ribuan catatan), aplikasi akan mengalami jank atau bahkan Out-Of-Memory (OOM).

Integritas & Konkurensi: Tidak mendukung transaksi ACID (atomic transaction). Jika aplikasi ditutup paksa saat serialisasi JSON sedang berlangsung, seluruh data catatan bisa rusak (corrupt) seketika.

Ketiadaan Query Mesin: Tidak bisa melakukan filter efisien seperti SELECT COUNT(*) WHERE dirty = 1 atau pengurutan ORDER BY updated_at DESC tanpa memuat seluruh catatan ke memori terlebih dahulu.

2. Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first)?
Cache-First Cukup Digunakan: Pada data yang sifatnya referensi statis, jarang berubah per detik, atau konten yang toleran terhadap stale data demi kecepatan pembukaan aplikasi (misalnya: artikel berita, daftar postingan blog/katalog, dan data profil pengguna).

Kebutuhan Network-First: Dibutuhkan pada domain yang menuntut keakuratan dan nilai terkini secara mutlak (strict consistency), seperti harga saham/kripto real-time, saldo e-wallet, status ketersediaan kursi tiket, atau konfirmasi transaksi pembayaran. Pada domain ini, menampilkan data usang (stale cache) dapat menimbulkan kerugian finansial atau kegagalan transaksi.

3. Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan tabel outbox menjadi perlu?
Mencegah UI Blocking: Proses penghitungan countDirty() dan simulasi upload dijalankan di background thread secara asynchronous (Future/Isolate). Antarmuka utama tetap responsif karena pembaruan badge dirty hanya mendengarkan state hasil kalkulasi tanpa menunggu respons jaringan selesai.

Kebutuhan Tabel Outbox Terpisah: Kolom dirty = 1 pada tabel notes hanya mencatat kondisi akhir baris data. Tabel Outbox/Mutation Queue terpisah menjadi wajib jika:

Perlu mencatat urutan operasi granular (misal: Create, lalu Update judul, lalu Delete).

Membutuhkan mekanisme retry, exponential backoff, atau pencatatan idempotency key per transaksi mutasi jaringan.

4. Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?
Rekomendasi yang Ditolak: Rekomendasi penggunaan SharedPreferences untuk menyimpan daftar koleksi catatan lokal secara serialisasi JSON, serta usulan dependensi reactive engine berbasis Hive/Drift dengan build_runner yang menambah ukuran boilerplate secara berlebihan.

Alasan Penolakan:

SharedPreferences ditolak untuk koleksi catatan karena rapuh, tidak memiliki indeks, dan tidak mendukung query agregasi antrean sync.

Dipilih kombinasi SharedPreferences murni untuk preferensi/flag dan SQLite (sqflite) untuk catatan, karena SQLite menyediakan transaksi ACID, query COUNT berindeks tinggi, dan deterministik tanpa beban code-generation.




# 05 - Week 5: Local Storage & Offline-First Notes App

Aplikasi catatan mobile berbasis Flutter yang mengimplementasikan arsitektur **Offline-First**, mencakup manajemen preferensi lokal, persistensi relasional SQLite, dan simulasi antrean sinkronisasi dua arah.

## Fitur Utama
1. **Preferensi Pengguna**: Toggle tema gelap/terang dan penyimpanan waktu akses terakhir menggunakan `SharedPreferences`.
2. **CRUD Catatan SQLite**: Persistensi penuh catatan lokal menggunakan `sqflite` dengan pengurutan otomatis berdasarkan `updated_at DESC`.
3. **Cache-First Posts**: Menampilkan data cache lokal dari tabel `cached_posts` seketika saat aplikasi dibuka, lalu melakukan sinkronisasi latar belakang via Dio.
4. **Antrean Sinkronisasi (Dirty Flag)**: Catatan baru atau editan lokal ditandai dengan flag `dirty = 1`. Saat online, tombol sync memproses antrean dan mengembalikan badge ke `0`.
5. **Mode Force-Offline**: Fitur simulasi pemutusan koneksi deterministik di halaman pengaturan untuk pengujian skenario offline tanpa mematikan koneksi sistem.
6. **Resolusi Konflik LWW**: Dokumentasi eksplisit aturan resolusi *Last-Write-Wins* berbasis perbandingan timestamp ISO-8601 UTC.

## Stack Teknologi
- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Local Storage**: 
  - `shared_preferences` (Theme & App state)
  - `sqflite` (Relational persistent storage & Caching)
- **Networking**: `dio`
- **Routing**: `go_router`

## Struktur Direktori
```text
05-week-5-local-storage-offline-first/
├── docs/
│   └── ai_challenge.md
├── screenshots/
│   ├── 1_offline_dirty.png
│   └── 2_online_synced.png
├── lib/
│   ├── data/
│   │   ├── local/
│   │   │   ├── db.dart
│   │   │   └── note.dart
│   │   ├── repositories/
│   │   │   └── notes_repositories.dart
│   │   ├── prefs.dart
│   │   └── sync.dart
│   ├── models/
│   │   └── post.dart
│   ├── pages/
│   │   ├── notes_page.dart
│   │   ├── note_detail_page.dart
│   │   └── settings_page.dart
│   ├── widgets/
│   │   └── note_tile.dart
│   └── main.dart
├── test/
│   └── note_test.dart
├── pubspec.yaml
└── README.md