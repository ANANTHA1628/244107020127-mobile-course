# Laporan Praktikum Minggu 4: REST API, State Management, & AI Challenge

## 1. Ringkasan Implementasi & Troubleshooting
* **Praktikum 1 & 2 (Dio & AsyncNotifier)**: Mengonfigurasi `ApiClient` dengan base URL JSONPlaceholder, membuat `PostRepository`, serta menangani berbagai status error HTTP (timeout, koneksi putus, 404, 500) menggunakan `friendlyErrorMessage`.
* **Praktikum 3 (Pagination & Infinite Scroll)**: 
  * Mengatasi kendala parsing list JSON pada response Dio dengan konversi tipe data yang aman: `Map<String, dynamic>.from(json as Map)`.
  * Memastikan infinite scroll berjalan mulus di perangkat fisik berlayar panjang dengan menyematkan `physics: const AlwaysScrollableScrollPhysics()` dan `NotificationListener<ScrollNotification>` agar trigger `loadNextPage()` terdeteksi dengan presisi saat mendekati ujung list.

---

## 2. AI Challenge: Layer Komentar (`GET /comments?postId={id}`)

### A. Prompt yang Digunakan
```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.

Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.