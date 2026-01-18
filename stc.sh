#!/bin/bash

CONFIG_FILE="config.json"
SU_CMD=$(which su)

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE tidak ditemukan!"
    exit 1
fi

echo "Mulai monitoring Multi-Window Grid..."
echo "Pastikan 'Enable Freeform Windows' aktif di Developer Options!"

while true; do
    # Loop config JSON
    for row in $(jq -r '.[] | @base64' "$CONFIG_FILE"); do
        _jq() {
         echo ${row} | base64 -d | jq -r ${1}
        }
        
        NAME=$(_jq '.name')
        PKG=$(_jq '.package')
        LINK_URL=$(_jq '.link')
        BOUNDS=$(_jq '.bounds')
        
        TIMESTAMP=$(date '+%H:%M:%S')

        # --- PERBAIKAN LOGIKA DETEKSI ---
        # GANTI: 'dumpsys' (deteksi sentuhan) MENJADI 'pidof' (deteksi nyala/mati)
        # Ini mencegah aplikasi di posisi lain ter-restart otomatis.
        if "$SU_CMD" -c "pidof $PKG" > /dev/null; then
            # Jangan spam log, diam saja kalau sudah jalan
            : 
        else
            echo "[$TIMESTAMP] ACTION: $NAME mati/crash. Membuka di posisi: $BOUNDS"
            
            # Kill dulu biar bersih memorinya
            "$SU_CMD" -c "am force-stop $PKG"
            
            # --- PERBAIKAN COMMAND START ---
            # 1. Ditambah --activity-clear-task : Menghapus histori posisi lama
            # 2. Ditambah --activity-new-task   : Memaksa buat window baru
            "$SU_CMD" -c "am start --user 0 \
                -a android.intent.action.VIEW \
                --activity-clear-task \
                --activity-new-task \
                --windowingMode 5 \
                --bounds $BOUNDS \
                -p $PKG \
                -d '$LINK_URL'" > /dev/null 2>&1
            
            echo "[$TIMESTAMP] INFO: $NAME berhasil dijalankan."
            
            # Wajib delay agak lama (15-20s) biar HP gak berat pas buka banyak app
            sleep 15
        fi
    done
    
    # Delay loop global
    sleep 5
done
