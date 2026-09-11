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




  refleksi

  1. Kapan setState masih cukup, dan kapan harus naik ke Riverpod?

setState: Untuk state lokal/sementara dalam satu widget (misal: buka-tutup dropdown, visibilitas password, animasi).

Riverpod: Untuk data global/lintas halaman, proses asinkron (API/database), atau logika yang perlu di-unit test terpisah dari UI.

2. Perbedaan context.go dan context.push, serta penggunaannya?

context.go: Navigasi deklaratif yang mengganti hierarki stack route (cocok untuk tab utama, deep link, dan login ke dashboard).

context.push: Menumpuk halaman baru di atas stack saat ini (cocok untuk alur detail atau form edit yang butuh tombol back kembali ke halaman pemanggil).

3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

Mencegah impossible states (mustahil loading dan error aktif bersamaan).

Memaksa penanganan tuntas (loading, error, data) via .when(), mencegah layar kosong (blank screen) dan null crash.

4. Bagian hasil AI yang diperbaiki dan alasannya?

Mengganti StateProvider ke Notifier karena versi modern sudah meninggalkan API lama tersebut.

Menggunakan Dart 3 switch expression agar penanganan filter tidak berpotensi mereturn null.

Merapikan sintaks underscore pada builder agar lolos aturan linter flutter analyze.