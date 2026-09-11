Hasil Pengamatan 3 State

Loading (AsyncLoading): Muncul indikator putar 2 detik pertama saat build() sedang menunggu proses Future.

Error (AsyncError): Muncul pesan gagal dan tombol Coba lagi karena throw Exception otomatis ditangkap Riverpod.

Success (AsyncData): Muncul daftar produk (ListView) setelah data berhasil di-return.

Fungsi Tombol "Coba Lagi" (ref.invalidate)

Mereset state provider dan memicu eksekusi ulang method build() dari awal untuk mencoba ambil data lagi tanpa restart aplikasi.

Jawaban Refleksi (Stale Data)

Alasan: Mencegah UI berkedip (layout jitter) dan menjaga alur baca pengguna tetap nyaman daripada melihat layar kosong putih.

Kapan Penting: Fitur pull-to-refresh, feed medsos/katalog, pencarian/filter cepat, dan kondisi sinyal tidak stabil (arsitektur offline-first).