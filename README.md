# Linux Sysadmin Toolkit

Kumpulan script bash untuk otomatisasi tugas administrasi Linux sehari-hari: membuat user, menghapus user, backup home directory, dan monitoring disk usage. Sebagian script sudah dijadwalkan berjalan otomatis lewat cron. Dibuat sebagai latihan bash scripting dengan fokus pada validasi input, error handling, dan automasi.

## Daftar Isi
- [Fitur](#fitur)
- [Requirement](#requirement)
- [Instalasi](#instalasi)
- [Cara Pakai](#cara-pakai)
  - [buat_user.sh](#buat_usersh)
  - [deluser.sh](#delusersh)
  - [backup_user.sh](#backup_usersh)
  - [disk_monitor.sh](#disk_monitorsh)
- [Automasi dengan Cron](#automasi-dengan-cron)
- [Catatan Teknis: Yang Saya Pelajari soal Cron](#catatan-teknis-yang-saya-pelajari-soal-cron)
- [Contoh Output](#contoh-output)
- [Struktur Proyek](#struktur-proyek)
- [Known Limitations](#known-limitations)

## Fitur

- ✅ Validasi wajib root sebelum eksekusi
- ✅ Validasi input tidak boleh kosong
- ✅ Cek keberadaan user/direktori sebelum melakukan aksi
- ✅ Pesan error dan sukses yang jelas untuk tiap skenario
- ✅ Backup otomatis harian & monitoring disk otomatis tiap 5 menit lewat cron

## Requirement

- Linux (diuji di Ubuntu Server)
- Bash 4+
- Akses root/sudo
- `cron` (biasanya sudah terpasang bawaan di Ubuntu Server; cek dengan `systemctl status cron`)

## Instalasi

```bash
git clone https://github.com/ilhamhabibb/Linux-Sysadmin-Toolkit.git
cd Linux-Sysadmin-Toolkit
chmod +x *.sh
```

## Cara Pakai

### buat_user.sh
Membuat user baru. Jika user sudah ada, script tidak membuat ulang dan memberi tahu bahwa user sudah ada.
```bash
sudo ./buat_user.sh nama_user
```

### deluser.sh
Menghapus user beserta home directory-nya. Menangani tiga skenario: user tidak ditemukan, user ditemukan tapi gagal dihapus (misal sedang login), dan berhasil dihapus.
```bash
sudo ./deluser.sh nama_user
```

### backup_user.sh
Membuat backup `.tar.gz` dari home directory user, disimpan di `/backup/user/`. Berguna dijalankan sebelum `deluser.sh` untuk menghindari kehilangan data.
```bash
sudo ./backup_user.sh nama_user
```
Hasil backup tersimpan dengan format:
```
/backup/user/backup_<nama_user>_<YYYY-MM-DD>.tar.gz
```

### disk_monitor.sh
Mengecek persentase pemakaian disk partisi root (`/`). Jika terpakai lebih dari 80%, script mencatat baris warning berisi timestamp ke file log. Jika masih di bawah threshold, script tidak menulis apa pun (supaya log tidak penuh data normal).
```bash
sudo ./disk_monitor.sh
cat /var/log/disk_monitor.log
```

## Automasi dengan Cron

Dua script di atas dijadwalkan berjalan otomatis lewat **crontab milik root** (`sudo crontab -e`), bukan crontab user biasa — supaya tidak perlu menyisipkan `sudo` di dalam baris perintah cron (`sudo` di crontab akan macet menunggu password yang tidak pernah bisa diketik saat job berjalan otomatis).

```cron
# Backup home directory user tertentu, setiap hari jam 02:00
0 2 * * * /path/lengkap/ke/backup_user.sh nama_user >> /var/log/backup_nama_user.log 2>&1

# Monitoring disk usage, dicek setiap 5 menit
*/5 * * * * /path/lengkap/ke/disk_monitor.sh
```

Catatan penting soal baris di atas:
- **Path harus absolut** (`/path/lengkap/...`), bukan relatif (`./nama_file.sh`) — cron tidak menjalankan perintah dari folder tertentu seperti sesi terminal interaktif, jadi path relatif tidak akan ditemukan.
- **Argumen (`nama_user`) ditulis langsung** di baris cron, karena tidak ada manusia yang bisa mengetik input lewat `read -p` saat job berjalan sendiri jam 2 pagi.
- **`>> file.log 2>&1`** menambahkan (bukan menimpa) semua output — termasuk pesan error — ke file log, supaya hasil eksekusi bisa dicek kapan saja tanpa harus menunggu di depan terminal.

Cara verifikasi crontab sudah tersimpan benar:
```bash
sudo crontab -l
```

## Catatan Teknis: Yang Saya Pelajari soal Cron

Selama belajar menjadwalkan script lewat cron, dua hal berikut ini yang menurut saya paling penting dipahami sebelum menaruh script produksi di crontab:

**1. Cron punya `PATH` yang jauh lebih terbatas dibanding sesi login biasa.**
Saat login manual, `$PATH` biasanya mencakup banyak folder (`/usr/local/bin`, `/usr/bin`, `/bin`, dst). Cron menjalankan job dengan `PATH` bawaan yang jauh lebih pendek. Akibatnya, script yang memanggil command di luar command dasar Linux (misal tools yang diinstall terpisah) bisa jalan normal saat dites manual, tapi gagal diam-diam saat dijalankan lewat cron karena command-nya "tidak ditemukan". Solusinya: selalu gunakan **path absolut** untuk script itu sendiri di baris crontab, dan kalau script memanggil command lain yang lokasinya tidak standar, tulis juga path absolutnya di dalam script atau set `PATH` secara eksplisit di baris awal script.

**2. `$HOME` untuk root berbeda dengan `$HOME` user biasa.**
Kalau sebuah script bergantung pada file konfigurasi di home directory (misalnya file tersembunyi seperti `~/.beberapa_config`), lokasi file itu ikut berubah tergantung siapa yang menjalankan script. Saat dites manual dengan `sudo`, `$HOME` kadang masih mengarah ke home directory user biasa. Tapi saat dijalankan murni lewat crontab root, `$HOME` root mengarah ke `/root`, bukan `/home/nama_user`. Kalau ada file pendukung yang dibutuhkan script, sebaiknya file itu memang ditempatkan di lokasi yang konsisten dengan user yang benar-benar menjalankan cron job-nya (root), bukan menumpang di folder milik user lain.

## Contoh Output

```
$ sudo ./backup_user.sh asep
Nama user tersedia
Direktori ada
tar: Removing leading `/' from member names
Backup user berhasil.
```

*(Tambahkan screenshot atau GIF terminal di sini untuk mempercantik dokumentasi.)*

## Struktur Proyek

```
linux-sysadmin-toolkit/
├── README.md
├── buat_user.sh
├── deluser.sh
├── backup_user.sh
└── disk_monitor.sh
```

## Known Limitations

- `backup_user.sh` akan menimpa file backup yang sudah ada jika dijalankan dua kali di hari yang sama untuk user yang sama.
- Belum ada validasi format nama user (misal karakter khusus/spasi).
- `disk_monitor.sh` hanya memantau partisi root (`/`); belum mendukung multi-partisi.
- Cron job di atas mengasumsikan timezone server sudah sesuai kebutuhan (cek dengan `timedatectl`). Perbedaan timezone antara server dan lokasi tim adalah hal yang wajib diperhatikan sebelum menjadwalkan job di server produksi.

---

Dibuat sebagai bagian dari proses belajar DevOps/Sysadmin.
