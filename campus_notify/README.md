StateYang DiharapkanCara UjiHasil PengamatanForegroundBanner lokal (heads-up) muncul saat aplikasi terbuka. Saat diklik, router membuka rute /pengumuman/3.Buka aplikasi di layar utama, biarkan aktif, kirim pesan dari Firebase Console. Klik banner yang muncul.Berhasil. Local notification memicu go('/pengumuman/3').BackgroundBanner sistem Android muncul di tray status bar. Saat diklik, aplikasi kembali aktif dan membuka /pengumuman/3.Buka aplikasi, tekan tombol Home (minimize), kirim notifikasi dari Console, klik notifikasi di tray.Berhasil. FirebaseMessaging.onMessageOpenedApp menerima data rute.TerminatedAplikasi terbuka dari awal dan langsung diarahkan ke /pengumuman/3 tanpa tertahan di layar awal.Tutup paksa aplikasi (swipe-close di Recent Apps), kirim pesan, klik notifikasi.Berhasil. getInitialMessage() menangkap payload saat aplikasi dibuka.



Jawaban Refleksi1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?SharedPreferences pada Android menyimpan data dalam bentuk berkas XML teks biasa (plaintext) tanpa enkripsi bawaan di direktori /data/data/<package_name>/shared_prefs/. Pada perangkat yang di-root, berkas ini dapat diekstraksi secara langsung menggunakan adb atau aplikasi pihak ketiga.Risiko Kebocoran: Berbeda dengan access token yang masa berlakunya singkat (misalnya 15–60 menit), refresh token berumur panjang (mingguan hingga bulanan). Jika penyerang berhasil mencuri refresh token, penyerang dapat terus menerus meminta access token baru (replay attack) dan memalsukan identitas mahasiswa tanpa batas waktu hingga masa aktifnya dicabut manual dari server.Solusi Keamanan: Menggunakan flutter_secure_storage yang memanfaatkan Android Keystore (KeyStore hardware-backed) dan enkripsi AES/RSA untuk menjaga integritas kredensial sesi.2. Apa yang rusak bila onTokenRefresh diabaikan selama satu semester perkuliahan?FCM token bukanlah identitas permanen perangkat. Token dapat diganti secara sepihak oleh Google Play Services apabila terjadi pembaruan aplikasi, pembersihan cache/data (clear data), pemulihan cadangan (restore backup), atau rotasi kunci keamanan periodik oleh Google.Dampak Sistem: Jika onTokenRefresh diabaikan, backend kampus akan terus menyimpan token basi (stale/invalid registration token).Akibatnya, server mengirim notifikasi ke alamat perangkat yang sudah kedaluwarsa. Mahasiswa tidak akan pernah menerima pengumuman penting (pembatalan kelas, batas akhir KRS/pembayaran, atau nilai keluar), dan server kampus menerima pesan eror UNREGISTERED / INVALID_ARGUMENT saat memanggil Firebase Cloud Messaging API.3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.KategoriBasis PengirimanMekanisme & KarakteristikContoh Pesan KampusTopik (Topic)One-to-Many (Broadcast / Multicast)Aplikasi berlangganan (subscribe) ke nama kanal publik tanpa perlu memetakan token mahasiswa secara individual di backend. Digunakan untuk pesan serentak berskala masif.- "Pengumuman Libur Nasional Hari Raya"- "Perubahan Kalender Akademik Semester Genap"- "Survei Evaluasi Dosen Jurusan Teknologi Informasi"Token Perangkat (Device Token)One-to-One (Unicast)Pesan dikirim secara spesifik ke registration token milik perangkat user tertentu. Digunakan untuk data privat, transaksional, atau keamanan.- "Tagihan UKT Semester 4 Anda telah terbit"- "KRS Anda telah disetujui oleh Dosen Pembina Akademik"- "Peringatan login akun baru terdeteksi"4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?Penolakan Method Class untuk Background Handler:Temuan: Draf awal asisten AI kerap membungkus background callback sebagai method di dalam kelas class PushService { Future<void> handle(...) }.Tindakan & Alasan: Callback tersebut ditolak dan dipindahkan ke fungsi top-level global dengan anotasi @pragma('vm:entry-point'). Background message Android berjalan di isolate Dart terpisah saat aplikasi terminated/background. Method kelas membutuhkan alokasi instance yang belum terbentuk pada isolate tersebut, yang menyebabkan runtime crash.Penolakan Penggunaan BuildContext pada Callback Notifikasi:Temuan: AI sering merekomendasikan Navigator.of(context).pushNamed(...) di dalam event listener FCM.Tindakan & Alasan: Callback background maupun stream onMessageOpenedApp dapat terpicu saat context widget belum terpasang (unmounted). Penanganan dialihkan menggunakan parameter callback murni void Function(String route) yang terhubung langsung ke GoRouter instance atau rootNavigatorKey.Penyensoran Token FCM untuk Log & UI:Temuan: AI mencetak nilai token FCM penuh ke console via print(token).Tindakan & Alasan: Mengganti log penuh menjadi fungsi masking maskToken() yang hanya menampilkan 12 karakter awal (substring(0, 12) + '...') untuk mencegah kebocoran kredensial di laporan praktikum.';



## Audit Layer Project (Praktikum 1)

| File | Layer Saat Ini | Masalah / Temuan Audit |
| :--- | :--- | :--- |
| `lib/pages/` | Presentation | Bersih dari panggilan network dan formatting langsung. |
| `lib/providers/auth_provider.dart` | Presentation (State) | Instansiasi langsung `AuthRepository()` (tight coupling). |
| `lib/data/api_client.dart` | Data | Inisialisasi global `Dio(BaseOptions(...))` tanpa dependency injection. |
| `lib/data/auth_repository.dart` | Data | Interface (kontrak) dan implementasi masih menyatu dalam satu file. |

lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart           # Wrapper Dio + Interceptor
│   │   └── api_endpoints.dart
│   └── storage/
│       └── secure_storage_client.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart  # Simpan token & user session
│   │   │   ├── models/
│   │   │   │   ├── auth_token_model.dart       # fromJson / toJson
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── auth_token.dart             # Pure Dart class
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart        # Abstract interface
│   │   │   └── usecases/
│   │   │       └── login_with_campus_id.dart   # Orkestrasi validasi + persistensi
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart        # Notifier / AsyncNotifier
│   │       ├── providers/
│   │       │   └── auth_providers.dart         # DI wiring (data source -> repo -> notifier)
│   │       └── pages/
│   │           └── login_page.dart
│   ├── announcements/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── announcement_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── announcement_model.dart     # fromJson mapping
│   │   │   └── repositories/
│   │   │       └── announcement_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── announcement.dart           # Pure Dart class
│   │   │   └── repositories/
│   │   │       └── announcement_repository.dart # Abstract interface
│   │   │   # Use cases ditiadakan untuk announcements (justifikasi pada Bagian 3)
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── announcement_controller.dart
│   │       ├── providers/
│   │       │   └── announcement_providers.dart
│   │       ├── pages/
│   │       │   ├── announcement_list_page.dart
│   │       │   └── announcement_detail_page.dart
│   │       └── widgets/
│   │           └── announcement_card.dart
│   └── notes/                                  # Modul catatan lokal SQLite yang sudah ada
├── messaging/                                  # Infrastruktur Firebase Cloud Messaging (Cross-cutting)
│   ├── push_service.dart
│   └── notification_payload_handler.dart
├── routes/
│   └── app_router.dart                         # GoRouter definitions
└── main.dart

2. Pemetaan & Migrasi File LamaFile LamaStatus TindakanLokasi & Penanganan BaruAlasan Teknislib/data/api_client.dartPindah & Rapikanlib/core/network/api_client.dartKlien HTTP (Dio) adalah utilitas lintas fitur, bukan milik satu domain tertentu.lib/data/api_errors.dartPecahlib/core/errors/exceptions.dart & failures.dartMemisahkan runtime exceptions (lapisan Data) dari domain failures (lapisan Domain/Presentation).lib/data/token_store.dartPecah & Bungkus- Wrapper umum: lib/core/storage/- Implementasi auth: lib/features/auth/data/datasources/auth_local_data_source.dartMenghindari akses storage acak; token auth harus diisolasi di bawah data source auth.lib/data/auth_repository.dartPecah (2 File)1. lib/features/auth/domain/repositories/auth_repository.dart2. lib/features/auth/data/repositories/auth_repository_impl.dartMenghilangkan percampuran antara kontrak interface abstrak dan implementasi Dio/Storage.lib/providers/auth_provider.dartPecah1. lib/features/auth/presentation/providers/auth_providers.dart2. lib/features/auth/presentation/controllers/auth_controller.dartMemisahkan binding dependency injection dari state mutation UI.lib/pages/login_page.dartPindahlib/features/auth/presentation/pages/login_page.dartMenempatkan UI di dalam fitur auth yang bersangkutan.lib/pages/announcement_page.dartPindah & Bersihkanlib/features/announcements/presentation/pages/announcement_detail_page.dartMenghapus pemanggilan Dio() langsung; memindahkan pembacaan data ke state notifier/provider.lib/pages/home_page.dartPindah / Rapikanlib/pages/home_page.dart (tetap sebagai dashboard shell)Berperan sebagai agregator navigasi utama.lib/pages/debug_token_page.dartPindahlib/messaging/debug_token_page.dartHalaman utilitas debugging FCM, dipisahkan dari alur aplikasi utama.lib/messaging/push_service.dartTetaplib/messaging/push_service.dartLayanan infrastruktur background thread FCM.

3. Analisis Pragmatis: Kapan Use Case Dibutuhkan vs Over-Engineering?
Menambahkan class UseCase untuk setiap operasi CRUD adalah bentuk over-engineering yang menghasilkan boilerplate kosong (pass-through class).

A. Fitur Announcements: Bypass Use Case (Langsung Notifier -> Repository)
Karakteristik: Fitur announcements hanya melakukan operasi query sederhana (getAnnouncements() dan getAnnouncementById(id)).

Keputusan Arsitektur: State Notifier / Provider langsung bergantung pada kontrak interface AnnouncementRepository.

Alasan Teknis: Jika Use Case dibuat, ia hanya berisi:

Dart
class GetAnnouncements {
  final AnnouncementRepository repo;
  GetAnnouncements(this.repo);
  Future<Result<List<Announcement>>> call() => repo.getAnnouncements();
}
Kelas satu baris seperti ini tidak memiliki logika bisnis, tidak mentransformasi model, dan tidak mengkoordinasi beberapa sumber data. Mengeliminasi kelas ini memangkas file redundan tanpa melanggar Inversion of Control.

B. Fitur Auth: Wajib Menggunakan Use Case
Karakteristik: Alur autentikasi melibatkan koordinasi multi-langkah dan aturan bisnis kritis.

Keputusan Arsitektur: Buat LoginWithCampusId Use Case.

Alasan Teknis:

Validasi format ID kampus/NIM dan kata sandi sebelum request jaringan.

Memanggil data source remote untuk pertukaran kredensial menjadi token JWT.

Menyimpan token ke penyimpanan lokal (AuthLocalDataSource).

Memicu registrasi token FCM ke backend melalui PushService.

Mengembalikan entitas User yang bersih.

Semua koordinasi lintas sumber data ini adalah domain logic yang tidak boleh bocor ke UI controller maupun terkunci di dalam satu HTTP repository.
