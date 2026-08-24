# Linux Sysadmin Toolkit

Kumpulan script bash untuk otomatisasi tugas administrasi user Linux sehari-hari: membuat user, menghapus user, dan backup home directory sebelum penghapusan. Dibuat sebagai latihan bash scripting dengan fokus pada validasi input, error handling, dan idempotency.

## Daftar Isi
- [Fitur](#fitur)
- [Requirement](#requirement)
- [Instalasi](#instalasi)
- [Cara Pakai](#cara-pakai)
  - [buat_user.sh](#buat_usersh)
  - [deluser.sh](#delusersh)
  - [backup_user.sh](#backup_usersh)
- [Contoh Output](#contoh-output)
- [Struktur Proyek](#struktur-proyek)
- [Known Limitations](#known-limitations)
- [Yang Saya Pelajari](#yang-saya-pelajari)

## Fitur

- ✅ Validasi wajib root sebelum eksekusi
- ✅ Validasi input tidak boleh kosong
- ✅ Cek keberadaan user/direktori sebelum melakukan aksi (menghindari error yang tidak jelas)
- ✅ Pesan error dan sukses yang jelas untuk tiap skenario
- ✅ Exit code yang konsisten untuk memudahkan integrasi ke script/pipeline lain

## Requirement

- Linux (diuji di Ubuntu 22.04/24.04)
- Bash 4+
- Akses root/sudo

## Instalasi

```bash
git clone https://github.com/username-kamu/linux-sysadmin-toolkit.git
cd linux-sysadmin-toolkit
chmod +x scripts/*.sh
```

## Cara Pakai

### buat_user.sh

Membuat user baru. Jika user sudah ada, script tidak akan membuat ulang dan memberi tahu bahwa user sudah ada.

```bash
sudo ./scripts/buat_user.sh nama_user
# atau tanpa argumen, akan diminta input interaktif
sudo ./scripts/buat_user.sh
```

### deluser.sh

Menghapus user beserta home directory-nya. Menangani tiga skenario: user tidak ditemukan, user ditemukan tapi gagal dihapus (misal sedang login), dan berhasil dihapus.

```bash
sudo ./scripts/deluser.sh nama_user
```

### backup_user.sh

Membuat backup `.tar.gz` dari home directory user, disimpan di `/backup/user/`. Berguna dijalankan sebelum `deluser.sh` untuk menghindari kehilangan data.

```bash
sudo ./scripts/backup_user.sh nama_user
```

Hasil backup akan tersimpan dengan format:
```
/backup/user/backup_<nama_user>_<YYYY-MM-DD>.tar.gz
```

## Contoh Output

```
$ sudo ./scripts/backup_user.sh budi
Nama user tersedia
Direktori ada
Backup user berhasil.
```



## Struktur Proyek

```
linux-sysadmin-toolkit/
├── README.md
├── scripts/
│   ├── buat_user.sh
│   ├── deluser.sh
│   └── backup_user.sh
└── examples/
    └── (screenshot/GIF contoh penggunaan)
```

## Known Limitations

- `backup_user.sh` akan menimpa file backup yang sudah ada jika dijalankan dua kali di hari yang sama untuk user yang sama (belum ada pengecekan overwrite).
- Belum ada validasi format nama user (misal karakter khusus/spasi).
- Script diuji di distro berbasis Debian/Ubuntu; belum diuji di RHEL/CentOS (`userdel`/`useradd` tersedia di keduanya, tapi ada sedikit perbedaan perilaku).

## Yang Saya Pelajari

Proyek ini adalah latihan pertama saya membangun toolkit bash dari nol, termasuk:
- Validasi input dan exit code (`$?`, `-eq`, `-ne`)
- Perbedaan mengecek keberadaan akun (`id`) vs keberadaan direktori (`-d`)
- Debugging logic flow (`if/else` bersarang, kapan harus `exit` vs lanjut)
- Kenapa `mv` bisa dihindari dengan menulis path tujuan langsung di `tar -czf`

---

Dibuat sebagai bagian dari proses belajar DevOps/Sysadmin.
