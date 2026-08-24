#!/bin/bash
tanggal=$(date +%Y-%m-%d)
#validasi user root
if [ "$EUID" -ne 0 ]; then
        echo "Anda haru login sebagai root"
        exit 1
fi 
#memasukan nama user yang mau dibackup
if [ -n "$1" ]; then
        username=$1
else
        read -p "Masukan nama user yang ingin dibackup: " username
fi
# konfirmasi agar user tidak memasukan input
if [ -z "$username" ]; then
        echo "user tidak boleh kosong"
        exit 1
fi
#Cek apakah user tersebut ada
if id "$username" &>/dev/null; then
	echo "Nama user tersedia"
else 
	echo "Nama user tidak ada"
	exit 1
fi

# cek apakah folder user tersebut ada
if [ -d "/home/$username" ]; then
        echo "Direktori ada"
else
        echo "Direktori tidak ditemukan"
        exit 1
fi      
#membuat folder backup
mkdir -p /backup/user/
if [ $? -ne 0 ]; then
	echo "Folder gagal dibuat"
	exit 1
fi
#membuat file zip
tar -czf /backup/user/backup_"$username"_"$tanggal".tar.gz /home/"$username"/
if [ "$?" -eq 0 ]; then 
	echo "Backup user berhasil."
else
        echo "gagal proses backup user"
        exit 1
fi

