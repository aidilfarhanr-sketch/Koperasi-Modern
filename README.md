# RaresMaju — Koperasi Digital Modern

![Status](https://img.shields.io/badge/status-demo%20project-blue)
![Stack](https://img.shields.io/badge/stack-HTML%20%7C%20CSS%20%7C%20JavaScript%20%7C%20PHP%20%7C%20MySQL-gold)
![Made By](https://img.shields.io/badge/made%20by-Aidil%20Farhan%20Rares-green)

**RaresMaju — Koperasi Digital Modern** adalah sistem koperasi berbasis web yang dibuat untuk membantu pengelolaan koperasi secara lebih rapi, modern, dan digital. Sistem ini menyediakan tampilan frontend modern, backend API PHP, database MySQL, dashboard, data anggota, simpanan, pinjaman, cicilan, transaksi, dokumen, SHU, notifikasi, dan activity log.

---

## Buka Tampilan HTML

Klik tombol ini untuk membuka tampilan HTML dari GitHub Pages:

**[Buka Demo HTML](https://aidilfarhanr-sketch.github.io/Koperasi-Modern/)**

Alternatif jika GitHub Pages belum aktif:

- **[Lihat file index.html](./index.html)**
- **[Lihat file HTML asli](./Koperasi_raresmaju.html)**

> Catatan: GitHub Pages hanya menjalankan file statis seperti HTML, CSS, dan JavaScript. Fitur backend PHP dan database MySQL tidak akan berjalan di GitHub Pages. Untuk menjalankan sistem penuh seperti login, dashboard data, simpanan, pinjaman, dan transaksi, gunakan XAMPP atau hosting yang mendukung PHP + MySQL.

---

## Tujuan Project

Project ini dibuat sebagai prototype sistem koperasi digital yang dapat digunakan untuk:

- Mengelola data anggota koperasi.
- Mencatat simpanan anggota.
- Mengelola pengajuan pinjaman.
- Mengelola cicilan dan pembayaran.
- Menampilkan dashboard ringkasan koperasi.
- Mengelola dokumen anggota dan dokumen transaksi.
- Menampilkan pembagian SHU.
- Mencatat aktivitas sistem melalui activity log.
- Menjadi bahan presentasi, portofolio, dan pengembangan sistem koperasi yang lebih lengkap.

---

## Gambaran Sistem

Alur kerja sistem:

```text
User membuka website
        ↓
index.html / Koperasi_raresmaju.html
        ↓
JavaScript memanggil API PHP di folder api/
        ↓
PHP memproses request
        ↓
PHP mengambil atau menyimpan data ke MySQL
        ↓
Data dikirim kembali ke frontend dalam format JSON
        ↓
Website menampilkan data ke pengguna
```

Dengan alur tersebut, project ini bukan hanya HTML statis. Tampilan utama berada di file HTML, sedangkan data sistem diproses melalui PHP API dan database MySQL.

---

## Fitur Utama

### 1. Landing Page Modern

Halaman awal dibuat dengan tampilan koperasi digital modern, animasi, desain responsive, dan penjelasan layanan koperasi.

### 2. Login dan Role Pengguna

Sistem memiliki role:

- **Admin**: mengelola sistem secara penuh.
- **Pengurus**: membantu pengelolaan koperasi.
- **Member**: anggota koperasi yang dapat melihat data dan melakukan pengajuan.

### 3. Dashboard Koperasi

Dashboard menampilkan ringkasan data koperasi seperti anggota, saldo, simpanan, pinjaman, cicilan, dan aktivitas penting.

### 4. Manajemen Anggota

Sistem dapat menampilkan dan mengelola data anggota koperasi, termasuk identitas, nomor anggota, status keanggotaan, alamat, kontak, dan informasi pendukung.

### 5. Manajemen Simpanan

Fitur simpanan digunakan untuk mencatat dan melihat data simpanan anggota, seperti simpanan pokok, wajib, sukarela, dan riwayat transaksi simpanan.

### 6. Manajemen Pinjaman

Fitur pinjaman digunakan untuk pengajuan pinjaman, persetujuan pinjaman, penolakan pinjaman, detail pinjaman, tenor, bunga, cicilan, dan status pinjaman.

### 7. Manajemen Cicilan

Sistem dapat mencatat pembayaran cicilan, jatuh tempo cicilan, total pembayaran, dan status pembayaran cicilan anggota.

### 8. Transaksi Koperasi

Sistem menyediakan pencatatan transaksi agar aktivitas keuangan koperasi lebih rapi dan mudah dipantau.

### 9. Dokumen

Fitur dokumen digunakan untuk menyimpan dokumen pendukung anggota atau transaksi, seperti gambar dan PDF.

### 10. SHU

Sistem memiliki fitur pembagian **Sisa Hasil Usaha (SHU)** berdasarkan data anggota, simpanan, dan pinjaman.

### 11. Activity Log

Setiap aktivitas penting dapat dicatat agar admin/pengurus bisa memantau perubahan dan tindakan di dalam sistem.

### 12. Responsive Design

Tampilan dibuat agar nyaman dibuka melalui laptop, desktop, tablet, dan HP.

---

## Teknologi yang Digunakan

| Bagian | Teknologi |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | PHP API |
| Database | MySQL / MariaDB |
| Local Server | XAMPP |
| Database Manager | phpMyAdmin |
| Chart | Chart.js |
| Icon | Remix Icon |
| Font | Google Fonts |
| Version Control | Git & GitHub |
| Static Preview | GitHub Pages / Netlify |

---

## Struktur Folder

```text
Koperasi-Modern/
│
├── index.html
├── Koperasi_raresmaju.html
├── koperasi_raresmaju.sql
├── README.md
├── netlify.toml
├── .gitignore
├── .nojekyll
├── Presentasi_RaresMaju_Elegant.pptx
│
└── api/
    ├── activity_log.php
    ├── auth.php
    ├── config.php
    ├── dashboard.php
    ├── documents.php
    ├── health.php
    ├── installments.php
    ├── loans.php
    ├── members.php
    ├── savings.php
    ├── shu.php
    ├── transactions.php
    │
    └── uploads/
```

---

## File Penting

| File / Folder | Fungsi |
|---|---|
| `index.html` | File utama agar GitHub Pages bisa langsung membuka tampilan website. |
| `Koperasi_raresmaju.html` | File HTML utama versi asli proyek. |
| `api/` | Folder backend PHP untuk proses login, dashboard, anggota, simpanan, pinjaman, cicilan, transaksi, dokumen, SHU, dan log aktivitas. |
| `api/config.php` | Konfigurasi koneksi database MySQL. |
| `api/health.php` | Mengecek apakah API dan database sudah terhubung. |
| `koperasi_raresmaju.sql` | File database yang harus di-import ke phpMyAdmin. |
| `README.md` | Dokumentasi project. |
| `netlify.toml` | Konfigurasi deploy frontend statis ke Netlify. |
| `.nojekyll` | Membantu GitHub Pages membaca file statis tanpa proses Jekyll. |

---

## Cara Upload ke GitHub

Repository tujuan:

```text
https://github.com/aidilfarhanr-sketch/Koperasi-Modern
```

Langkah upload lewat website GitHub:

1. Buka repository **Koperasi-Modern**.
2. Klik **uploading an existing file** atau klik **Add file** lalu pilih **Upload files**.
3. Extract ZIP project terlebih dahulu.
4. Upload isi folder project, bukan ZIP mentahnya.
5. Pastikan file yang ada di root repository minimal seperti ini:

```text
index.html
README.md
Koperasi_raresmaju.html
koperasi_raresmaju.sql
api/
netlify.toml
```

6. Isi commit message:

```text
Initial commit RaresMaju Koperasi Digital
```

7. Klik **Commit changes**.

---

## Cara Membuat HTML Bisa Dibuka dari README

Agar tombol **Buka Demo HTML** di README bisa berjalan, aktifkan GitHub Pages:

1. Buka repository **Koperasi-Modern**.
2. Masuk ke **Settings**.
3. Pilih menu **Pages**.
4. Pada bagian **Build and deployment**, pilih:

```text
Source: Deploy from a branch
Branch: main
Folder: / root
```

5. Klik **Save**.
6. Setelah aktif, buka link:

```text
https://aidilfarhanr-sketch.github.io/Koperasi-Modern/
```

Jika link belum langsung aktif, tunggu proses deploy GitHub Pages selesai. Biasanya akan muncul tanda centang hijau di bagian deployment.

---

## Cara Menjalankan Sistem Penuh di XAMPP

Gunakan cara ini jika ingin fitur PHP dan database berjalan.

### 1. Pindahkan Folder ke htdocs

Pindahkan folder project ke:

```text
C:\xampp\htdocs\Koperasi-Modern
```

### 2. Jalankan XAMPP

Buka XAMPP Control Panel, lalu jalankan:

```text
Apache
MySQL
```

### 3. Buat Database

Buka:

```text
http://localhost/phpmyadmin
```

Buat database baru dengan nama:

```text
koperasi_raresmaju
```

### 4. Import Database

Masuk ke database `koperasi_raresmaju`, lalu import file:

```text
koperasi_raresmaju.sql
```

### 5. Jalankan Website

Buka:

```text
http://localhost/Koperasi-Modern/
```

atau:

```text
http://localhost/Koperasi-Modern/index.html
```

### 6. Cek Koneksi API dan Database

Buka:

```text
http://localhost/Koperasi-Modern/api/health.php
```

Jika berhasil, API akan menampilkan response JSON sukses.

---

## Konfigurasi Database

Konfigurasi database ada di file:

```text
api/config.php
```

Default konfigurasi:

```php
DB_HOST = 127.0.0.1
DB_NAME = koperasi_raresmaju
DB_USER = root
DB_PASS = kosong
DB_PORT = 3306
```

Jika memakai hosting online, sesuaikan nama database, username database, password database, dan host database dari cPanel atau penyedia hosting.

---

## Akun Login Contoh

Setelah database berhasil di-import, gunakan akun berikut:

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `Password123!` |
| Pengurus | `pengurus1` | `Password123!` |
| Member | `budi_s` | `Password123!` |
| Member | `siti_r` | `Password123!` |
| Member | `agus_w` | `Password123!` |

---

## API Endpoint Utama

| Endpoint | Fungsi |
|---|---|
| `api/health.php` | Cek koneksi API dan database. |
| `api/auth.php` | Login, logout, register, dan session user. |
| `api/dashboard.php` | Data dashboard admin/member. |
| `api/members.php` | Data anggota koperasi. |
| `api/savings.php` | Data simpanan anggota. |
| `api/loans.php` | Data pengajuan dan status pinjaman. |
| `api/installments.php` | Data cicilan dan pembayaran. |
| `api/transactions.php` | Data transaksi koperasi. |
| `api/documents.php` | Data dokumen/upload. |
| `api/shu.php` | Data SHU anggota. |
| `api/activity_log.php` | Riwayat aktivitas sistem. |

---

## Catatan Penting Deployment

### GitHub Pages

GitHub Pages cocok untuk membuka tampilan HTML dari README.

Yang berjalan:

- HTML
- CSS
- JavaScript frontend
- Tampilan landing page
- Preview UI

Yang tidak berjalan:

- PHP API
- Login database
- MySQL
- Upload file backend
- Session PHP

### Hosting PHP + MySQL

Untuk menjalankan sistem penuh, gunakan hosting yang mendukung:

- PHP
- MySQL / MariaDB
- phpMyAdmin
- File upload
- Session PHP

Contoh hosting yang cocok:

- XAMPP untuk lokal
- cPanel hosting
- VPS
- Hostinger
- InfinityFree untuk demo terbatas

---

## Troubleshooting

### 1. Demo HTML GitHub Pages 404

Pastikan:

- File `index.html` ada di root repository.
- GitHub Pages sudah aktif dari branch `main` dan folder `/ root`.
- Repository sudah public atau Pages mendukung repository tersebut.

### 2. Login tidak jalan di GitHub Pages

Itu normal, karena GitHub Pages tidak menjalankan PHP dan MySQL. Jalankan melalui XAMPP atau hosting PHP + MySQL.

### 3. API error di localhost

Cek:

- Apache aktif.
- MySQL aktif.
- Database `koperasi_raresmaju` sudah dibuat.
- File `koperasi_raresmaju.sql` sudah di-import.
- Konfigurasi `api/config.php` sesuai.

### 4. Halaman dibuka lewat file langsung tetapi fitur error

Jangan buka dengan format:

```text
file:///C:/...
```

Gunakan:

```text
http://localhost/Koperasi-Modern/
```

---

## Status Project

Project ini siap digunakan untuk:

- Upload ke GitHub.
- Dokumentasi README.
- Preview HTML melalui GitHub Pages.
- Demo frontend statis.
- Pengujian sistem penuh melalui XAMPP.
- Pengembangan lanjutan ke hosting PHP + MySQL.

---

## Pembuat

Dibuat oleh:

```text
Aidil Farhan Rares
```

Project ini dapat digunakan sebagai bahan pembelajaran, tugas, presentasi, dan portofolio pengembangan web berbasis HTML, JavaScript, PHP, dan MySQL.
