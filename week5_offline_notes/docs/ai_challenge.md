# AI Challenge: Perbandingan Storage & Verifikasi

## 1. Tabel Perbandingan Storage Engine

| Storage Engine | Kompleksitas Query | Kebutuhan Relasi | Reaktivitas (Stream) | Type-Safety | Boilerplate & Setup | Kemudahan Testing | Rekomendasi Penggunaan |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SharedPreferences** | Sangat Rendah (Key-Value sederhana) | Tidak Mendukung | Tidak Ada (Manual Notifier) | Parsial (Primitive types saja) | Sangat Minim (Nol setup file) | Mudah (Mocking lewat memory) | **Preferensi Tema** (`is_dark_mode`, token, flag) |
| **Hive** | Rendah (Filter/Search in-memory) | Tidak Mendukung (No relational engine) | Built-in via `ValueListenable` / Stream | Tinggi (Jika pakai TypeAdapter generated) | Sedang (Perlu `build_runner`) | Mudah (Mendukung in-memory box) | Alternatif cache JSON / NoSQL |
| **sqflite (SQLite)** | Tinggi (Full ANSI SQL, Index, Join) | Mendukung (Foreign Keys, Cascade) | Manual (Perlu StreamController / Notifier) | Rendah (Raw Map `Map<String, dynamic>`) | Rendah-Sedang (Tulis SQL manual, migrasi manual) | Sedang (Perlu mock sqflite atau FFI di desktop) | **Daftar Catatan Offline** (Standar Codelab) |
| **Drift (Moor)** | Sangat Tinggi (SQL murni + Query Builder Dart) | Sangat Mendukung (Strong typing relation) | Native Built-in (`watch()` query auto-update) | Sangat Tinggi (Compile-time checked code-gen) | Tinggi (Wajib `drift_dev`, `build_runner`, file `.g.dart`) | Sangat Mudah (In-memory testing native) | **Daftar Catatan Skala Besar** (Alternatif lanjutan) |

---

## 2. Rekomendasi Final & Alasan Pemilihan

| Kebutuhan | Storage Terpilih | Justifikasi Utama |
| :--- | :--- | :--- |
| **Preferensi Tema** | **SharedPreferences** | Ringan, operasi read/write instan untuk primitive boolean, tanpa overhead dependensi code generator. |
| **Daftar Catatan (Notes)** | **sqflite** | Membutuhkan filtering query agregasi (`COUNT(*) WHERE dirty = 1`), pengurutan `updated_at DESC`, serta menjaga performa saat data bertambah hingga 1000+ data. |

---

## 3. Skema Database untuk 1000+ Catatan (Antrean Sync)

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  dirty INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL
);

-- Indeks performa untuk mempercepat filter dan sorting
CREATE INDEX idx_notes_dirty ON notes (dirty);
CREATE INDEX idx_notes_updated_at ON notes (updated_at DESC);


