# AI Log — Minggu 10: Integrasi Fitur AI (AI Feature Integration)

**Nama Mahasiswa:** Muhammad Anantha Rezky  
**NIM:** 244107020127  
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** #10 — Integrasi Fitur AI  
**Tanggal:** 2 November 2026  

---

## 1. Desain Prompt (Formula Prompt Mobile)

Untuk mengintegrasikan LLM API (Google Gemini) ke aplikasi mobile `campus_notify` secara aman dan efisien, diterapkan komponen prompt terstruktur:

| Komponen | Implementasi Prompt | Tujuan & Peran |
|:---|:---|:---|
| **System Prompt** | `"Kamu adalah asisten kampus Polinema yang ramah, sopan, dan informatif. Jawab dalam Bahasa Indonesia dengan ringkas, maksimal 2-3 kalimat. Jangan pernah meminta atau membocorkan data pribadi mahasiswa."` | Menetapkan persona AI, membatasi panjang respons (menghemat token & biaya), dan menetapkan batas keamanan data. |
| **User Prompt** | `"Jadwal kuliah hari Senin?", "Bagaimana cara melihat pengumuman kampus?", "Cara membuat catatan di menu Notes?"` | Pertanyaan spesifik dari mahasiswa melalui antarmuka chat. |
| **Konteks** | Identitas institusi Polinema, fitur lokal yang ada di aplikasi (`/notes`, `/pengumuman`, Siakad). | Memberikan relevansi kontekstual lokal kampus agar jawaban akurat. |
| **Batasan (Limits)** | Sanitasi lokal terhadap NIK (16 digit) dan nomor kontak (`08...`/`+628...`). Validasi offline jika API down. | Menjaga privasi, menghindari kebocoran data sensitif ke cloud API provider, serta mencegah biaya bengkak. |

---

## 2. Prompt Rekayasa Kode AI (AI Assisted Coding)

Berikut adalah prompt yang digunakan saat mengembangkan modul `AiService` dan `ChatScreen`:

```text
Peran: Senior Flutter & Mobile AI Engineer
Konteks: Project Flutter 'campus_notify' dengan Riverpod, GoRouter, flutter_secure_storage, dan http/dio.
Tugas:
1. Buat AiService di lib/ai/ai_service.dart:
   - Integrasikan Google Gemini API (model gemini-pro / generateContent).
   - Simpan & ambil API key dari FlutterSecureStorage (key: 'ai_api_key').
   - Buat Privacy Guard: cegah NIK (16 digit) & nomor telepon sebelum terkirim ke API.
   - Buat Cache in-memory lokal agar pertanyaan yang sama tidak memicu pemanggilan API berulang (Cost & Rate-limit Mitigation).
   - Sediakan streaming emulasi via Stream<String> askStream(String question).
   - Sediakan Smart Offline Fallback response jika server AI 500/503 atau tanpa internet.
2. Buat ChatScreen di lib/features/chat_screen.dart:
   - Antarmuka chat responsif dengan bubble pengguna dan bot.
   - Empty state informatif dengan chips saran prompt interaktif.
   - Indikator typing / streaming response.
   - Dialog error ramah dengan tombol beralih ke Mode Offline jika API error.
   - Tombol dialog pengaturan API Key.
   - Fitur Salin Teks (Clipboard) dan Regenerate Respons.
Batas:
- Analisis statis wajib bersih (flutter analyze 0 issues).
- Testable (bisa diuji via MockClient tanpa memanggil API riil).
- Jangan kirim data identitas pengguna ke AI API.
```

---

## 3. Output Awal AI & Evaluasi Kritis

### Output Mentah Awal dari AI:
1. AI awalnya menyarankan menyimpan API key langsung di konstanta file Dart (`static const String apiKey = '...'`).
2. AI awalnya tidak memasang regex filter privasi di client side, hanya mengandalkan prompt engineering teks.
3. AI awalnya menggunakan `http.post` langsung di dalam widget `StatefulWidget` tanpa pemisahan kelas service yang independen.

### Tindakan Verifikasi & Refactoring (Oleh Pengembang):
| No | Isu yang Ditemukan | Risiko | Tindakan Refactoring | Status |
|:---:|:---|:---|:---|:---:|
| 1 | Hardcoded API key di source code | Kebocoran kredensial di repositori Git publik | Dipindahkan ke `FlutterSecureStorage` dengan dialog input aman di aplikasi | **DIPERBAIKI** |
| 2 | Tidak ada Privacy Guard di client | Pelanggaran UU PDP jika user mengetik NIK | Ditambahkan `validatePrivacy()` lokal menggunakan regex NIK 16 digit dan nomor telepon | **DIPERBAIKI** |
| 3 | Panggilan API berulang tanpa cache | Biaya token membengkak dan kena HTTP 429 Rate Limit | Ditambahkan Map in-memory cache `_cache` di `AiService` | **DIPERBAIKI** |
| 4 | Ketiadaan fallback saat internet mati | Pengguna frustrasi saat server AI down | Dibuat `getOfflineFallbackResponse()` dengan fallback dialog ramah pengguna | **DIPERBAIKI** |
| 5 | Widget terikat ketat dengan HTTP network | Sulit dilakukan automated unit test | Di-refactor sehingga `AiService` menerima opsional `http.Client`, memungkinkan `MockClient` di unit test | **DIPERBAIKI** |

---

## 4. Log Keputusan Arsitektur

```text
[Flutter UI: ChatScreen]
       │
       ▼ (Validasi Privasi Lokal)
[AiService.validatePrivacy] ──(Sensitif)──► [Tolak & Tampilkan Alert Merah]
       │ (Aman)
       ▼ (Cek Cache)
[In-Memory Cache] ──(Ada di Cache)────────► [Kembalikan Langsung (Hemat Token)]
       │ (Tidak ada)
       ▼ (Ambil Kunci Aman)
[FlutterSecureStorage: ai_api_key]
       │
       ├─► (API Berhasil 200) ──► [Simpan ke Cache] ──► [Stream ke UI]
       │
       └─► (Error / Offline)  ──► [Dialog Fallback] ──► [Data Lokal Kampus]
```

---

## 5. Bukti Uji Otomatis & Analisis

- `flutter analyze`: **0 Issues found (100% Bersih)**
- `flutter test`: **33/33 Tests Passed (100% Hijau)**
  - 11 Unit Test `AiService` (Privacy Guard, Cache hit, JSON Parsing, Offline Fallback, HTTP error handling, Token streaming).
  - 3 Widget Test `ChatScreen` (Empty state rendering, Privacy alert presentation, Fallback dialog & offline mode switch).
  - 19 Test yang sudah ada sebelumnya (Notes use case, Search, Repository, FCM routes).
