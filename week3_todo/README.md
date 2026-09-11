Hasil Pengamatan 3 State

Loading (AsyncLoading): Muncul indikator putar 2 detik pertama saat build() sedang menunggu proses Future.

Error (AsyncError): Muncul pesan gagal dan tombol Coba lagi karena throw Exception otomatis ditangkap Riverpod.

Success (AsyncData): Muncul daftar produk (ListView) setelah data berhasil di-return.

Fungsi Tombol "Coba Lagi" (ref.invalidate)

Mereset state provider dan memicu eksekusi ulang method build() dari awal untuk mencoba ambil data lagi tanpa restart aplikasi.

Jawaban Refleksi (Stale Data)

Alasan: Mencegah UI berkedip (layout jitter) dan menjaga alur baca pengguna tetap nyaman daripada melihat layar kosong putih.

Kapan Penting: Fitur pull-to-refresh, feed medsos/katalog, pencarian/filter cepat, dan kondisi sinyal tidak stabil (arsitektur offline-first).






AI CHALENGE 

### AI Verification Checklist & Findings

- **State Immutability**: Terverifikasi aman. Seluruh pembaruan state menggunakan instance baru melalui `AsyncValue.guard()`, menghindari mutasi memori langsung pada list.
- **Scoping `WidgetRef`**: Terverifikasi sesuai kaidah. `ref.watch` memicu auto-rebuild UI secara tepat sasaran, dan `ref.read` memanggil notifier method tanpa membuat langganan reaktif berlebih.
- **Async State Coverage**: Tidak ada cabang kondisi yang terlewat (`loading`, `error`, dan `data` terisi penuh), mencegah bug *blank screen* atau *unhandled exception*.
- **API Modernization**: Mengadopsi kelas `AsyncNotifier`, menggantikan pola usang `StateNotifierProvider`.
- **Quality Assurance**:
  - `flutter analyze`: 0 warnings, 0 errors.
  - `flutter test`: Seluruh pengujian asynchronous notifier passed (100%).