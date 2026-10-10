# AI Verification & Technical Audit: Push Notification Implementation

Dokumen audit ini mencatat hasil verifikasi independen atas draf kode Push Notification Service yang di-generate oleh AI coding assistant.

---

### 1. Verification Matrix

| Komponen Audit | Status Kelayakan | Temuan & Analisis Teknis | Tindakan Perbaikan |
| :--- | :---: | :--- | :--- |
| **Top-Level Background Handler** | **VALID** | Fungsi `firebaseMessagingBackgroundHandler` berada di root file dengan anotasi `@pragma('vm:entry-point')`. Tidak ditempatkan di dalam class method sehingga tidak crash saat isolate background diaktifkan oleh Android OS. | Pertahankan fungsi di top-level. |
| **Pencegahan Akses BuildContext** | **VALID** | Seluruh routing notifikasi menggunakan callback `void Function(String route) onNavigate` yang dikaitkan ke router instance / GlobalKey navigator, bukan `Navigator.of(context)` atau `BuildContext` lokal. | Memisahkan callback navigasi dari widget tree. |
| **Sinkronisasi Token Lifecycle** | **VALID** | `onTokenRefresh` dan `getToken()` memanggil `_sendTokenToBackend()` via client `Dio.post('/devices')` secara langsung, bukan sekadar mencetak `print(token)`. | Endpoint siap menerima token pembaruan rotasi sistem. |
| **Manual Local Notification (Foreground)** | **VALID** | `FirebaseMessaging.onMessage` memicu `_local.show()` secara eksplisit dengan channel `Importance.high` agar banner heads-up muncul saat user aktif di dalam aplikasi. | Banner heads-up berjalan di foreground. |
| **Keamanan Token & Data Sensitif** | **VALID** | Nilai raw FCM token tidak di-hardcode ke konstanta kode dan tidak di-log penuh ke console. Log console hanya menampilkan 12 karakter pertama (`substring(0, 12) + '...'`). | Token terlindungi dari kebocoran log. |
| **Handling Tiga App State** | **VALID** | Menangani Foreground (`onMessage`), Background (`onMessageOpenedApp`), dan Terminated (`getInitialMessage`). Payload `data['route']` berhasil dipetakan ke rute aplikasi. | Dibuktikan lewat matriks pengujian runtime. |

---

### 2. Perbedaan Kritis Arsitektur Platform

1. **Android 13+ (API 33+)**:
   - Membutuhkan izin runtime eksplisit `POST_NOTIFICATIONS`.
   - Membutuhkan `AndroidNotificationChannel` ber-prioritas tinggi agar notification banner heads-up muncul di atas aplikasi.
2. **iOS (APNs)**:
   - Membutuhkan permission via `requestPermission(alert: true, badge: true, sound: true)`.
   - Menggunakan delegates internal iOS (`DarwinInitializationSettings`) untuk foreground presentation.

---

### 3. Matriks Hasil Pengujian 3 App State

| State | Payload Pengujian | Expected Behavior | Actual Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Foreground** | `route: "/pengumuman/3"`, `id: "3"` | Banner heads-up lokal muncul di layar; saat ditekan, router membuka `/pengumuman/3`. | Banner lokal muncul, diklik berhasil berpindah ke `/pengumuman/3`. | **PASS** |
| **Background** | `route: "/pengumuman/3"`, `id: "3"` | Notifikasi muncul di status bar tray; diklik mengembalikan aplikasi ke foreground dan langsung navigasi. | Tray notifikasi menampilkan pesan; saat diklik rute berpindah akurat. | **PASS** |
| **Terminated** | `route: "/pengumuman/3"`, `id: "3"` | Aplikasi melakukan *cold boot* dari tray notifikasi dan langsung membuka `/pengumuman/3`. | Aplikasi terbuka, `getInitialMessage` membaca payload dan meredirect rute. | **PASS** |

---

### 4. Keputusan Teknis Final
- Menghindari penulisan logic token di dalam file antarmuka (UI). Seluruh token dikendalikan oleh `PushService` dan dipadukan dengan dependency injection Riverpod.
- Token FCM yang ditampilkan pada halaman `DebugTokenPage` wajib melalui filter `maskToken()` untuk menjaga kredensial perangkat saat pembuatan tangkapan layar laporan.