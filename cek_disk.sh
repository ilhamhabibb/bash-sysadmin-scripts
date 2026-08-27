#!/bin/bash

# Konfigurasi
THRESHOLD=1
LOG_FILE="/var/log/disk_monitor.log"

# Mengambil persentase pemakaian disk partisi root (/)
# df --output=pcent / : Hanya menampilkan kolom persentase
# tail -n 1           : Mengambil baris kedua (mengabaikan header "Use%")
# tr -dc '0-9'        : Menghapus spasi dan simbol '%', menyisakan angka saja
DISK_USAGE=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')

# Cek apakah pemakaian melebihi threshold
if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    # Generate timestamp dengan format: YYYY-MM-DD HH:MM:SS
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Catat warning ke file log
    echo "[$TIMESTAMP] WARNING: Partisi root (/) hampir penuh! Saat ini terpakai ${DISK_USAGE}%." >> "$LOG_FILE"
fi
