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


REFLEKSI
1. Mengapa UI dilarang memanggil Dio secara langsung? Apa yang rusak jika aturan ini dilanggar?
Pemisahan Tanggung Jawab (Separation of Concerns): Tanggung jawab widget UI murni untuk merender visual dan menangani interaksi pengguna. UI tidak boleh dibebani logika HTTP, konfigurasi header, query parameter, ataupun parsing JSON mentah.

Dampak Kerusakan jika Aturan Dilanggar:

Sulit Diuji (Untestable): Widget UI menjadi tidak bisa diuji secara terisolasi via widget/unit test karena akan selalu menembak jaringan internet sungguhan, alih-alih menggunakan mock/fake repository.

Kerapuhan & Duplikasi Kode (Tight Coupling): Bila URL endpoint atau skema response JSON dari backend berubah, developer terpaksa mengubah banyak file UI satu per satu.

State Tidak Konsisten: Sulit menyelaraskan caching dan status data (loading/error) jika beberapa widget memanggil Dio sendiri-sendiri tanpa sinkronisasi state manager.

2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server-side (_page/_limit)?
Client-Side Pagination Cukup Jika:

Total data kecil dan terbatas (misalnya di bawah 100–200 item).

Data cenderung statis dan jarang diperbarui oleh server, sehingga efisien di-fetch sekaligus di awal lalu dipecah menggunakan manipulasi list lokal (sublist).

Aplikasi membutuhkan filter dan pencarian instan tanpa perlu latensi jaringan di setiap interaksi input.

Server-Side Pagination Wajib Digunakan Jika:

Volume data sangat besar, bertambah terus-menerus, atau berpotensi mencapai ribuan baris (seperti linimasa media sosial atau katalog e-commerce).

Diperlukan penghematan kuota data pengguna, efisiensi konsumsi memori (RAM), serta waktu muat awal (initial load time) yang singkat pada perangkat mobile.

3. Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
Mekanisme Otomatis Riverpod:

Di dalam method Future<T> build() milik AsyncNotifier (maupun FutureProvider), Riverpod secara internal telah membungkus proses asynchronous ke dalam blok penanganan error. Jika repository melempar exception (misal: DioException), Riverpod otomatis menangkapnya dan mengubah state provider menjadi AsyncError(error, stackTrace). Di sisi UI, kita cukup mengonsumsinya secara deklaratif via ref.watch(provider).when(...).

Kapan try/catch Eksplisit Tetap Dibutuhkan?:

Operasi Mutasi Pengguna: Pada aksi yang dipicu event tombol (misalnya submit form, update data, delete item), agar kita bisa menampilkan feedback langsung seperti SnackBar atau dialog saat operasi gagal.

Pagination Manual: Pada method seperti loadNextPage(), di mana kegagalan fetch halaman berikutnya tidak boleh menghapus data yang sudah tampil sebelumnya (currentItems), melainkan hanya mereset flag isLoadingMore = false dan mencatat error tambahan.

4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
Sintaks Inheritance Provider Riverpod: Kode awal hasil AI mencoba meng-extend FamilyAsyncNotifier secara langsung tanpa dukungan code generation, sehingga memicu error kompilasi Dart (undefined ref dan state). Kode diperbaiki menjadi subclass AsyncNotifier standar dengan parameter ID pada constructor yang diintegrasikan lewat AsyncNotifierProvider.family.

Casting JSON pada Dio Response: Generator kode AI menggunakan filter .whereType<Map<String, dynamic>>(). Karena Dio sering membaca respons list sebagai Map<dynamic, dynamic>, pemetaan awal tersebut membuang semua data dan menghasilkan list kosong. Diperbaiki dengan konversi eksplisit: Map<String, dynamic>.from(json as Map).

Scroll Physics & Trigger Listener: Listener scroll bawaan AI tidak terpicu pada perangkat fisik beresolusi tinggi karena 10 item awal belum memenuhi batas tinggi layar (unscrollable). Ditambahkan physics: const AlwaysScrollableScrollPhysics() dan NotificationListener<ScrollNotification> agar scroll pagination terpicu secara konsisten.