## Aturan Konflik Sinkronisasi (Conflict Resolution)

Mekanisme yang digunakan adalah **Last-Write-Wins (LWW)** berbasis metadata `updated_at`:
1. Setiap entri lokal maupun server mencatat timestamp UTC saat data dibuat/dimodifikasi.
2. Ketika sinkronisasi dua arah dijalankan:
   - Data lokal dengan nilai `updated_at` yang lebih baru akan menimpa data di server.
   - Jika versi server memiliki timestamp yang lebih baru atau setara, data lokal digantikan oleh versi server dan flag `dirty` di-reset ke `0`.
3. Pendekatan ini mencegah penimpaan data secara diam-diam (*silent overwrite*) tanpa memerlukan antarmuka penyelesaian konflik manual yang rumit bagi pengguna.