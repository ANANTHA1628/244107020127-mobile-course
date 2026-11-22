# 🚀 Minggu 13 — CI/CD & Automation

**Nama Mahasiswa:** Muhammad Anantha Rezky (244107020127)  
**Mata Kuliah:** Pemrograman Mobile — Modul #13  
**Tanggal:** 22 November 2026  

---

## 📌 Deskripsi

Folder ini berisi konfigurasi **CI/CD Pipeline** menggunakan GitHub Actions untuk project `campus_notify`. Pipeline ini mengotomatiskan alur kerja *Development-to-Release* untuk menjaga kualitas kode dan konsistensi artefak sebelum dideploy.

### Pipeline Flow:
1.  **Trigger:** Aktif saat `push` atau `pull_request` ke branch `main`.
2.  **Environment:** `ubuntu-latest` dengan Flutter SDK (channel `stable`).
3.  **CI Steps:** 
    *   `flutter pub get`: Mengunduh dependensi.
    *   `dart format`: Memastikan seluruh kode mengikuti standar style.
    *   `flutter analyze --fatal-infos`: Pemeriksaan statis kode yang ketat.
    *   `flutter test --coverage`: Menjalankan suite pengujian dan melaporkan cakupan kode.
4.  **CD Steps (Build & Publish):**
    *   `flutter build apk --release`: Build APK untuk testing internal.
    *   `flutter build appbundle --release`: Build AAB untuk distribusi Play Store.
    *   `actions/upload-artifact`: Menyimpan output build sebagai artefak selama 7 hari.

---

## 🏗️ Konfigurasi Workflow

Konfigurasi disimpan di `.github/workflows/flutter-ci.yml`:

```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
      - run: flutter build apk --release
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
```

---

## 🔍 Status Keamanan & Risiko

| Risiko Keamanan | Mitigasi |
|:---|:---|
| **Hardcoded Secrets** | Tidak ada API Key atau Keystore yang disimpan di `.yml`. Kunci API dikonfigurasi melalui runtime/SecureStorage. |
| **Penyalahgunaan Runner** | `concurrency` diaktifkan untuk membatalkan build lama jika ada *push* baru ke branch yang sama (hemat resource). |
| **Izin Runner** | Dibatasi dengan `permissions: contents: read` agar pipeline tidak dapat melakukan modifikasi *repo* tanpa otorisasi. |

---

## 📈 Rencana Rilis & Versi Berikutnya

| Komponen | Status Saat Ini | Versi Berikutnya (Target) | Alasan |
|:---|:---:|:---:|:---|
| **App Version** | `1.0.0` | `1.1.0` | Penambahan fitur AI Chat dan Pipeline CI/CD (Minor update). |
| **Build Number** | `+1` | `+2` | Identifikasi unik untuk setiap upload ke Play Store/Internal Test. |
| **Git Tag** | `-` | `v1.1.0` | Menandai titik stabil kode yang lolos pipeline CI/CD. |

---

## 🎫 Refleksi

### 1. Masalah apa yang ditemukan otomatis sebelum perubahan di-merge?
> **Jawaban:** Pemeriksaan otomatis `flutter analyze` akan menolak kode yang memiliki *unused import*, penamaan class yang tidak konsisten, atau *null-safety violation*. `flutter test` akan menolak *merge* jika ada perubahan yang mematahkan logika bisnis (misal: validasi input yang tiba-tiba gagal). Ini mencegah *regresi* sebelum sampai ke tangan pengguna.

### 2. Informasi apa yang dibutuhkan untuk menyelidiki build yang gagal?
> **Jawaban:** 
> *   **Action Logs:** Mengetahui *step* mana yang gagal (misal: apakah gagal di `analyze` atau `test`?).
> *   **Exit Code:** Untuk menentukan apakah build gagal karena *syntax error* atau masalah *tooling* environment.
> *   **Artifact:** Jika build lulus tapi aplikasi tidak berjalan, artefak (APK) membantu untuk *debugging* pada perangkat fisik secara langsung.

### 3. Bagian mana yang masih perlu persetujuan atau pemeriksaan manual sebelum rilis?
> **Jawaban:** 
> *   **Manual QA:** Otomatisasi hanya menjamin kode "lulus test", bukan menjamin "fitur sesuai keinginan user".
> *   **Signing Keystore:** Untuk rilis produksi, file `.keystore` tidak boleh disimpan di Git. Harus dikelola lewat GitHub Secrets yang aman.
> *   **Rilis Play Store:** Mengunggah AAB ke *Google Play Console* tetap memerlukan peninjauan manual, deskripsi rilis, dan validasi *policy* keamanan Google.
