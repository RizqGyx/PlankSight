<!-- PROJECT LOGO -->
<br />
<div align="center">
  <img src="https://img.icons8.com/color/100/yoga.png" alt="Logo" width="80" height="80">

  <h1 align="center">PlankSight</h1>

  <p align="center">
    <strong>Aplikasi iOS Cerdas untuk Memperbaiki Postur Plank Anda Secara <i>Real-Time</i></strong>
    <br />
    Menggunakan Vision Framework & Machine Learning secara On-Device.
    <br />
    <br />
    <a href="#-fitur-utama"><strong>Jelajahi Fitur »</strong></a>
    <br />
    <br />
    <a href="#-tangkapan-layar">Lihat UI</a>
    ·
    <a href="#-cara-menjalankan">Cara Install</a>
    ·
    <a href="#-kontribusi">Lapor Bug</a>
  </p>
</div>

---

## 🎯 Tentang Proyek

**PlankSight** (atau *Berzki*) adalah aplikasi kebugaran berbasis iOS yang menggunakan perpaduan teknologi Apple Vision dan SwiftUI. Aplikasi ini dirancang untuk memastikan pengguna melakukan gerakan *Plank* dengan postur tubuh yang benar guna menghindari cedera dan memaksimalkan hasil latihan yang terukur. 

Alih-alih hanya menyediakan timer kosong (stopwatch reguler), PlankSight memanfaatkan kamera depan/belakang device Anda untuk memindai struktur tulang dan memberikan umpan balik (feedback) secara langsung!

---

## ✨ Fitur Utama

- 📸 **Deteksi Postur Real-Time (AI-Powered)**: Secara pintar melacak 5 titik penting tubuh *(Kepala, Bahu, Punggung, Pinggul, Lutut)* berkat implementasi Vision Body Pose Estimation.
- ⏱️ **Timer Pintar & Otomatis**: *Stopwatch* akan mulai berhitung mundur otomatis **hanya** saat Anda sudah dalam posisi plank yang sempurna.
- 🗣️ **Umpan Balik Instan (*Live Feedback*)**: Menerima peringatan secara langsung apabila postur tubuh menjadi tidak ideal selama latihan berlangsung (Contoh: *"Pinggul Anda terlalu rendah"*).
- 📊 **Sistem Analitik & Riwayat**: 
  - Melacak *Total Waktu Plank*.
  - Menghitung persentase detik dengan postur sempurna (*Good Form*) vs postur buruk (*Bad Form*).
- ⚙️ **Kustomisasi Durasi**: Menyediakan fitur pemilihan waktu secara spesifik atau melaju ke mode latihan tanpa batas *(Free-Time)*.
- 👨‍🏫 **Panduan & Onboarding**: Mengajarkan orientasi perangkat dan bagaimana melakukan postur yang aman beserta peringatan *Form-Correction*.

---

## 📱 Tangkapan Layar

*(Ganti URL gambar di bawah dengan screenshot asli setelah aplikasi di-build)*

| Panduan & Onboarding | Setel Waktu (Setup) | Kamera Layar & Feedback | Analitik Akhir |
| :---: | :---: | :---: | :---: |
| <img src="https://via.placeholder.com/200x420.png?text=Panduan+View" width="200" /> | <img src="https://via.placeholder.com/200x420.png?text=Setel+Waktu" width="200" /> | <img src="https://via.placeholder.com/200x420.png?text=Camera+Tracking" width="200" /> | <img src="https://via.placeholder.com/200x420.png?text=Summary/History" width="200" /> |

---

## 🛠️ Teknologi yang Digunakan

Proyek menggunakan *stack* teknologi Apple modern:

- **Bahasa**: [Swift 5.9+](https://developer.apple.com/swift/)
- **Antarmuka (UI)**: [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- **Machine Learning & Visi Komputer**: Apple Vision Framework `VNDetectHumanBodyPoseRequest`
- **Asynchronus & State Management**: `Combine`, `@StateObject`, `NavigationStack` (AppRouter)
- **Arsitektur Utama**: MVVM (Model-View-ViewModel)

---

## ⚙️ Persyaratan Sistem

- iOS 16.0 atau lebih baru (Sangat direkomendasikan iOS 17+)
- Xcode 15.0 atau lebih baru
- Perangkat iOS fisik (**iPhone/iPad**) sangat direkomendasikan untuk uji coba pelacakan kamera. *(Simulator Mac tidak mendukung pengambilan instrumen kamera depan/belakang)*.

---

## 🚀 Cara Menjalankan (Instalasi Lokal)

Untuk mendapatkan salinan repositori dan menjalankannya sangatlah mudah.

1. **Clone Repositori ini**
   ```sh
   git clone https://github.com/USERNAME-ANDA/PlankSight.git
   ```
2. Buka Folder Proyek.
   ```sh
   cd PlankSight
   ```
3. Buka File `.xcodeproj` Menggunakan Xcode.
   ```sh
   open Berzki.xcodeproj
   ```
4. Hubungkan perangkat Anda via USB atau WiFi dan pilih kapabilitas *signing* (App ID pengguna) di menu Target.
5. Tekan tombol  **Play** (atau `Cmd + R`) untuk melakukan proses *Build and Run*.
6. Jangan lupa pastikan opsi untuk mengakses kamera di setujui (*Privacy - Camera Usage Description*).

---

## 🤝 Kontribusi

Kami sangat terbuka untuk kontribusi Anda! Jika Anda memiliki ide meningkatkan akurasi *machine-model*, menambahkan fitur riwayat lanjut, atau sekadar memperbaiki *bug*.

1. Dapatkan *Fork* proyek ini
2. Buat branch fitur Anda (`git checkout -b feature/FiturBrilliant`)
3. Commit penambahan kode (`git commit -m 'Membuat fitur Brilliant 2.0'`)
4. Push ke branch referensi (`git push origin feature/FiturBrilliant`)
5. Kirimkan satu **Pull Request** ke Repositori ini

---

## Lisesi & Kontak

Project ini di kembangkan oleh **Muhammad Rizki**.
Lisensi standar tersedia di repositori terkait. Apabila ingin berinteraksi silahkan tinggalkan *Issue* GitHub.

 <p align="right">(<a href="#readme-top">kembali ke atas</a>)</p>
