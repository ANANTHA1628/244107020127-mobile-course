# Template Pull Request (PR)

Gunakan format ini saat membuat Pull Request di GitHub dari branch `feature/*` atau `fix/*` menuju branch `develop`:

---

### Judul PR: `feat(notes): validasi judul kosong + test`

#### 1. Masalah
Pengguna saat ini masih dapat menyimpan catatan tanpa judul atau hanya berisi spasi whitespace kosong. Hal ini menyebabkan database lokal SQLite menyimpan record kosong dan memicu kegagalan saat background synchronization ke REST API backend.

#### 2. Solusi
- Menambahkan pemeriksaan validasi `title.trim().isEmpty` pada layer domain / use case catatan.
- Mengembalikan objek `ValidationFailure` jika judul tidak memenuhi syarat.
- Menampilkan pesan error yang ramah pengguna pada form input catatan di Presentation layer.
- Menambahkan unit test untuk memverifikasi kegagalan validasi ketika judul kosong.

#### 3. Cara Pengujian
1. Jalankan aplikasi pada simulator / emulator / Windows desktop.
2. Buka modal tambah catatan baru.
3. Tekan tombol simpan tanpa mengisi judul atau hanya mengisi spasi -> Pesan peringatan "Judul catatan tidak boleh kosong" harus muncul dan catatan tidak tersimpan.
4. Jalankan pengujian otomatis di terminal:
   ```bash
   flutter test test/validate_note_test.dart
   flutter analyze
   ```

#### 4. Kesiapan Mesin (CI / Pre-Review Checklist)
- [x] `flutter analyze` bersih (0 warning, 0 error).
- [x] `dart format` terformat rapi.
- [x] Seluruh unit test lulus (`All tests passed!`).
- [x] Ukuran PR < 300 baris kode baru.

Closes #12
