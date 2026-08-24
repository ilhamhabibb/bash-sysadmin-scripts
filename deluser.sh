#!/bin/bash
# Script: deluser.sh
# Fungsi : Menghapus user secara otomatis.
#          - Jika user tidak ditemukan -> tampilkan pesan "user tidak ada"
#          - Jika user ditemukan tapi gagal dihapus -> tampilkan pesan gagal
#          - Jika user ditemukan dan berhasil dihapus -> tampilkan pesan sukses
#
# Cara pakai:
#   sudo ./deluser.sh nama_user
#   atau jalankan tanpa argumen untuk diminta input nama user
#

# Harus dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Anda bukan root, login terlebih dahulu."
    exit 1
fi

# Ambil username dari argumen, atau minta input jika kosong
if [ -n "$1" ]; then
    username="$1"
else
    read -p "Masukkan user yang ingin anda hapus: " username
fi

# Validasi input tidak kosong
if [ -z "$username" ]; then
    echo "User tidak boleh kosong."
    exit 1
fi

# Cek apakah user ada, lalu proses penghapusan
if id "$username" &>/dev/null; then
    userdel -r "$username"

    if [ "$?" -eq 0 ]; then
        echo "User '$username' berhasil dihapus."
    else
        echo "User '$username' ditemukan, tetapi gagal dihapus (mungkin sedang login atau ada proses yang masih berjalan)."
    fi
else
    echo "User '$username' tidak ada."
fi
