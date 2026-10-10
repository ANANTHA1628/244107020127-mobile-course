# Evaluasi AI Architecture Challenge & Decision Log

## 1. Prompt AI yang Digunakan
> "Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman). Kondisi kini: folder lib/{data, providers, pages, messaging}, repository tercampur dengan implementasi, widget memanggil Dio langsung. Tugas: 1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data) untuk fitur auth + announcements. 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus). 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case benar-benar dibutuhkan vs repository langsung. 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan). Jelaskan trade-off setiap keputusan."

## 2. Tabel Usulan vs Keputusan Final

| Komponen Arsitektur | Usulan Awal AI | Keputusan Final Pengembang | Alasan Teknis |
| :--- | :--- | :--- | :--- |
| **Use Case Announcements** | Dibuatkan `GetAnnouncementsUseCase` terpisah | **Ditolak (Bypass Use Case)** | Operasi query satu baris. Cukup binding interface repository langsung ke Riverpod `FutureProvider`. |
| **Use Case Auth** | Dibuatkan `LoginWithCampusId` Use Case | **Diterima** | Mengorkestrasikan input sanitization, API login, penyimpanan JWT ke secure storage, dan sync FCM token. |
| **Lokasi Repository Interface** | Di dalam `domain/repositories/` | **Diterima** | Menerapkan Dependency Inversion Principle; domain independen dari implementasi network/DB. |
| **Entity Mapping (`fromJson`)**| Mapping ditaruh di dalam `Entity` | **Ditolak (Pindah ke Model)** | Entity harus murni kode Dart. Mapping `fromJson`/`toJson` hanya boleh ada di `data/models/`. |
| **DI Container** | Menggunakan Riverpod bawaan | **Diterima** | Terintegrasi langsung dengan reactive state tanpa perlu service locator pihak ketiga seperti `GetIt`. |