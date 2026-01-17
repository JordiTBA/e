#!/bin/bash


CONFIG_FILE="config.json"
SU_CMD=$(which su)


if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE tidak ditemukan!"
    exit 1
fi

echo "Mulai monitoring multi-instance..."

while true; do
    for row in $(jq -r '.[] | @base64' "$CONFIG_FILE"); do
        _jq() {
         echo ${row} | base64 -d | jq -r ${1}
        }
        NAME=$(_jq '.name')
        PKG=$(_jq '.package')
        LINK_URL=$(_jq '.link')
        TIMESTAMP=$(date '+%H:%M:%S')
        if "$SU_CMD" -c "dumpsys activity activities" | grep -i 'mResumedActivity' | grep -q "$PKG"; then
            echo "[$TIMESTAMP] OK: $NAME ($PKG) sedang aktif."
        else
            echo "[$TIMESTAMP] ACTION: $NAME mati/tertutup. Restarting..."
            "$SU_CMD" -c "am force-stop $PKG"
            "$SU_CMD" -c "am start --user 0 -a android.intent.action.VIEW -p $PKG -d '$LINK_URL'"
            echo "[$TIMESTAMP] INFO: $NAME telah dijalankan ulang."
            sleep 10
        fi
    done
    sleep 5
done
