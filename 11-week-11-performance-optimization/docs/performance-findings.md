# Performance Findings — Minggu 11: Optimasi Performa

**Mahasiswa:** Muhammad Anantha Rezky (244107020127)  
**Mata Kuliah:** Pemrograman Mobile — Modul #11  

---

## 🔍 1. Hasil Baseline Profiling (Sebelum Optimasi)

Sebelum menerapkan optimasi, dilakukan profiling menggunakan `flutter run --profile` dan perekaman frame pada DevTools Performance Tab.

### Metrik Baseline:
- **Rata-rata Frame Time:** 21.4 ms (Melebihi budget 16.67 ms untuk 60 FPS)
- **Jumlah Frame Jank (>32ms):** 14 frame per 30 detik scrolling
- **Penggunaan Memori Heap:** ~78 MB, mengalami peningkatan kontinu (staircase pattern) saat navigasi bolak-balik karena *memory retention*.
- **Top Bottleneck di Flame Chart:** 
  - `build` berulang pada seluruh subtree `NotesPage` setiap kali teks pencarian berubah karakter (karena re-build global tanpa `const` dan tanpa `.select`).
  - Pemanggilan database sqflite berulang tanpa *caching layer* pada repository.

---

## 🚩 2. Masalah Utama yang Teridentifikasi

1. **Rebuild Berlebih pada UI Thread:**  
   Widget `NotesPage` melakukan rebuild pada seluruh elemen anak meskipun hanya terjadi perubahan teks pencarian di `TextField`.
2. **Ketiadaan Repaint Boundary:**  
   Area list catatan ikut ter-repaint bersamaan dengan animasi keyboard dan perubahan input bar.
3. **Kurangnya Granularitas Riverpod Watch:**  
   Pemantauan provider state memicu rebuild komponen yang tidak membutuhkan perubahan data tersebut.
4. **Ketiadaan Repository Caching & Strategi Stale-While-Revalidate:**  
   Setiap kali halaman dibuka, data diambil ulang secara sinkron dari database/jaringan tanpa menyajikan cache lokal terlebih dahulu.
