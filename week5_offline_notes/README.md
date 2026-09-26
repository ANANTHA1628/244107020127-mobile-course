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