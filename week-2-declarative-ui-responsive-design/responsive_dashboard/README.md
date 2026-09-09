# Tugas Week 2 - Responsive Academic Overview Dashboard

Aplikasi dashboard akademik mahasiswa berbasis Flutter yang dibuat responsif untuk tampilan layar sempit maupun lebar, mendukung pergantian tema manual (dark/light mode), serta ramah aksesibilitas (screen reader).

---

## Fitur Utama yang Diimplementasikan
* Header Profil: Menampilkan ringkasan identitas mahasiswa menggunakan kombinasi Container, Row, Column, Expanded, dan CircleAvatar.
* Kartu Informasi Reusable: Menyediakan 4 kartu metrik (IPK, SKS Lulus, Presensi, Tugas) yang dipisah ke dalam widget InfoCard agar modular.
* Tata Letak Responsif: Memanfaatkan LayoutBuilder. Layar sempit (< 700px) menggunakan 1 kolom, sedangkan layar lebar (>= 700px) otomatis beralih menjadi 2 kolom.
* Dual Theme: Menyediakan toggle manual dark/light mode menggunakan CupertinoSwitch di AppBar. Warna komponen otomatis menyesuaikan tema lewat Theme.of(context).
* Aksesibilitas: Komponen penting dan kartu data dibungkus menggunakan Semantics agar terbaca runtut oleh screen reader.

---

## Refactoring Kode
* Breakpoint dipusatkan ke dalam konstanta kWideBreakpoint = 700.0 agar mudah diatur dan tidak duplikat.
* Memisahkan komponen berulang ke widget mandiri (InfoCard dan ProfileHeaderCard) agar kode lebih rapi.
* Mengganti pewarnaan statis dengan Theme.of(context).colorScheme agar tampilan tetap terbaca jelas di kedua mode tema.

---

## Catatan AI Challenge

1. Eksplorasi Desain: GridView vs LayoutBuilder + Column
* Pertanyaan: Membandingkan penggunaan GridView dengan LayoutBuilder + Column untuk dashboard akademik.
* Pilihan yang diambil: LayoutBuilder + GridView.count yang diletakkan di dalam SingleChildScrollView.
* Alasan teknis: GridView memudahkan pembagian grid yang proporsional dan rapi. Scroll bentrok diatasi dengan menambahkan shrinkWrap: true dan NeverScrollableScrollPhysics().

2. Konsep Overflow Expanded pada Row
* Pembahasan: Expanded di dalam Row akan error (unbounded width) apabila diletakkan di dalam scrollview horizontal yang tidak membatasi lebar.
* Solusi: Menghindari pemakaian Expanded di dalam wadah horizontal tanpa batas, atau membatasi ukuran Row menggunakan SizedBox.

3. Verifikasi Layout dan Aksesibilitas
* Tampilan di bawah 600px tetap responsif menjadi 1 kolom tanpa overflow vertikal.
* Label suara pada kartu sudah digabung menjadi satu kesatuan kalimat melalui Semantics.
* Seluruh widget yang digunakan merupakan widget stabil bawaan Flutter.

---

## Hasil Pengujian
* flutter analyze: No issues found.
* flutter test: All tests passed (lulus pada pengujian lebar 400px dan 1200px).
* Tangkapan layar hasil tampilan tersimpan pada folder screenshots