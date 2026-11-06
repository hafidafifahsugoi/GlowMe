# 🌸 GlowMe — Pendamping Perawatan Kulit & Ketenangan Batin

**GlowMe** adalah aplikasi mobile perawatan diri dan kesehatan kulit (*holistic skincare & mindfulness companion*) berbasis Flutter yang membantu pengguna merawat kesehatan kulit dari luar sekaligus menjaga ketenangan pikiran dari dalam. Dilengkapi dengan pelacak rutinitas skincare harian, jurnal perkembangan kondisi kulit (*multi-condition skin tracker*), grafik analitik interaktif, serta ruang *mindfulness* inklusif berisi afirmasi positif, *manifesting*, refleksi diri, dan doa harian.

## ✨ Fitur Utama

- 🧴 **Pelacak Rutinitas Skincare Harian (*Daily Skincare Routine*)** Membuat dan mengelola tahapan produk perawatan kulit pagi maupun malam secara terstruktur, dilengkapi *checklist* interaktif dan indikator progres penyelesaian harian di halaman Beranda.
- 📸 **Jurnal & Dokumentasi Kondisi Kulit (*Multi-Condition Skin Tracker*)** Mencatat perkembangan kondisi kulit setiap hari lengkap dengan dokumentasi foto wajah, pemilihan berbagai kondisi kulit sekaligus dalam satu catatan (*Bercahaya, Lembap, Kering, Kemerahan, Berminyak, Berjerawat*), skor kenyamanan kulit (1–10), serta catatan refleksi diri.
- 📊 **Analitik & Grafik Perkembangan Kulit (*Skin Progress Analytics*)** Memvisualisasikan tren tingkat kenyamanan kulit dari waktu ke waktu menggunakan grafik garis interaktif, rata-rata skor kesehatan kulit, serta deteksi status tren kulit otomatis (*Membaik, Stabil, atau Menurun*).
- 🌿 **Ruang Mindfulness, Afirmasi & Spiritual Inklusif** Menyediakan tiga kategori penenang batin—*Afirmasi & Manifesting*, *Refleksi & Mindfulness* (termasuk teknik pernapasan 4-7-8), serta *Doa & Dzikir Harian*—yang dilengkapi panduan praktik dan penghitung ketukan interaktif (*Tap Counter*).
- 🌗 **Antarmuka Lembut & Estetik (*Light & Dark Mode*)** Didesain dengan palet warna *soft dusty rose, sage green, & warm cream* yang menenangkan mata, serta mendukung pergantian tema terang maupun gelap secara instan dan pengingat notifikasi terjadwal.
- 🔒 **Autentikasi & Sinkronisasi Cloud Real-Time** Terintegrasi dengan Firebase Authentication & Cloud Firestore untuk menyimpan profil pengguna, jadwal rutinitas, dan riwayat jurnal kulit secara aman dan *real-time*.

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Backend & Database:** Firebase Auth, Cloud Firestore, Firebase Storage, Shared Preferences
- **Data Visualization:** FL Chart (`fl_chart`)
- **Multimedia & Notifications:** `image_picker`, `cached_network_image`, `flutter_local_notifications`, `timezone`
- **UI & Typography:** Material 3, Google Fonts (Inter), `intl` (Lokalisasi Bahasa Indonesia)

## 🚀 Cara Menjalankan Project

1. **Clone repository ini**
   ```bash
   git clone https://github.com/hafidafifahsugoi/GlowMe.git
   cd GlowMe
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```
