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
        if "$SU_CMD" -c "dumpsys activity activities" | grep -i 'mResumedActivity' | grep -q "$PKG"; then
            echo "[$TIMESTAMP] INFO: $NAME sedang berjalan. Melewati..."
            
        else
            echo "[$TIMESTAMP] ACTION: $NAME mati/crash. Membuka di posisi: $BOUNDS"
            "$SU_CMD" -c "am force-stop $PKG"
            
            "$SU_CMD" -c "am start --user 0 \
                -a android.intent.action.VIEW \
                --windowingMode 5 \
                --bounds $BOUNDS \
                -p $PKG \
                -d '$LINK_URL'" > /dev/null 2>&1
            echo "[$TIMESTAMP] INFO: $NAME berhasil dijalankan."
            sleep 15
        fi
    done
    sleep 5
done
