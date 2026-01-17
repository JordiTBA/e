# Cari lokasi su otomatis
SU_CMD=$(which su)

while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    
    # Cek Roblox (tetap pakai full path buat dumpsys biar aman)
    if "$SU_CMD" -c "/system/bin/dumpsys window windows" | grep -i 'mCurrentFocus' | grep -q 'com.asepv2.mobu'; then
        echo "[$TIMESTAMP] OK: Roblox sedang dimainkan."
    else
        echo "[$TIMESTAMP] ACTION: Roblox tidak di layar. Melakukan auto-join..."
        
        # Kill app
        "$SU_CMD" -c "/system/bin/am force-stop com.asepv2.mobu"
        
        # Start app (pastikan satu baris)
        "$SU_CMD" -c "/system/bin/am start --user 0 -a android.intent.action.VIEW -d 'roblox://placeId=121864768012064&linkCode=29945061429931940452490641554963'"
        
        sleep 20
    fi
    sleep 5
done
