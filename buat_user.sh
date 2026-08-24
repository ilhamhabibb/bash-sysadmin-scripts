#!/bin/bash
#
# Script: buat_user.sh
# Fungsi : Membuat user baru secara otomatis.
#          Jika user sudah ada, script akan menampilkan pesan
#          bahwa user sudah ada dan tidak membuat ulang.
#
# Cara pakai:
#   sudo ./newuser.sh nama_user
#   atau jalankan tanpa argumen untuk diminta input nama user
#

# Pastikan dijalankan sebagai root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Script ini harus dijalankan sebagai root (gunakan sudo)."
    exit 1
fi

# Ambil nama user dari argumen, atau minta input jika kosong
if [ -n "$1" ]; then
    USERNAME="$1"
else
    read -p "Masukkan nama user yang ingin dibuat: " USERNAME
fi

# Validasi input tidak kosong
if [ -z "$USERNAME" ]; then
    echo "Nama user tidak boleh kosong."
    exit 1
fi

# Cek apakah user sudah ada
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' sudah ada."
else
    # Buat user baru beserta home directory-nya
    useradd -m "$USERNAME"

    if [ $? -eq 0 ]; then
        echo "User '$USERNAME' berhasil dibuat."

        # (Opsional) set password untuk user baru
        # Hapus tanda pagar di bawah ini jika ingin langsung set password interaktif
        # passwd "$USERNAME"
    else
        echo "Gagal membuat user '$USERNAME'."
        exit 1
    fi
fi
