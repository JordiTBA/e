#!/bin/bash

CONFIG_FILE="config.json"
SU_CMD=$(which su)

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE tidak ditemukan!"
    exit 1
fi

echo "--- MONITORING MULTI-WINDOW (SAFE MODE) ---"

while true; do
    for row in $(jq -r '.[] | @base64' "$CONFIG_FILE"); do
        _jq() {
         echo ${row} | base64 -d | jq -r ${1}
        }
        
        NAME=$(_jq '.name')
        PKG=$(_jq '.package')
        LINK_URL=$(_jq '.link')
        # Kita ambil bounds, tapi kita ubah formatnya (koma jadi spasi) buat perintah resize nanti
        RAW_BOUNDS=$(_jq '.bounds')
        RESIZE_BOUNDS=$(echo $RAW_BOUNDS | tr ',' ' ')
        
        TIMESTAMP=$(date '+%H:%M:%S')

        # Cek apakah app jalan
        if "$SU_CMD" -c "pidof $PKG" > /dev/null; then
            : 
        else
            echo "---------------------------------------------------"
            echo "[$TIMESTAMP] ACTION: Membuka $NAME..."
            
            # 1. Kill dulu
            "$SU_CMD" -c "am force-stop $PKG"
            
            # 2. START APP (TANPA BOUNDS)
            # Kita hapus --bounds disini biar gak error "Unknown option"
            "$SU_CMD" -c "am start --user 0 \
                -a android.intent.action.VIEW \
                --display 0 \
                --windowingMode 5 \
                -p $PKG \
                -d '$LINK_URL'" > /dev/null 2>&1
            
            echo "[$TIMESTAMP] INFO: App diluncurkan. Menunggu sistem..."
            sleep 5 
            
            # 3. COBA RESIZE MANUAL (EXPERIMENTAL)
            # Kita cari Task ID dari aplikasi yang baru dibuka
            # Perintah ini mencoba mencari ID tugas di Android buat di-resize paksa
            echo "[$TIMESTAMP] INFO: Mencoba mengatur posisi..."
            
            # Ambil Task ID (Script agak rumit karena output android beda-beda)
            TASK_ID=$("$SU_CMD" -c "am stack list" 2>/dev/null | grep "$PKG" | head -n 1 | awk '{print $2}' | sed 's/[:#]//g')
            
            # Jika 'am stack list' gagal, coba metode dumpsys (cadangan)
            if [ -z "$TASK_ID" ]; then
                TASK_ID=$("$SU_CMD" -c "dumpsys activity activities" | grep -B 2 "$PKG" | grep "TaskRecord" | head -n 1 | awk '{print $2}' | sed 's/[:#]//g')
            fi

            # Kalau dapet ID-nya, kita resize!
            if [ ! -z "$TASK_ID" ]; then
                "$SU_CMD" -c "am task resize $TASK_ID $RESIZE_BOUNDS" > /dev/null 2>&1
                echo "[$TIMESTAMP] SUCCESS: Posisi diatur ke $RAW_BOUNDS (Task ID: $TASK_ID)"
            else
                echo "[$TIMESTAMP] WARN: Gagal detect Task ID. App terbuka di posisi default."
            fi
            
            echo "---------------------------------------------------"
            sleep 10
        fi
    done
    sleep 5
done
