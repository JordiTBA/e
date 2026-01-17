# Cari lokasi su otomatis (Best Practice)
SU_CMD=$(which su)

while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    
    # 1. Cek apakah Mod Roblox (Mobu) ada di layar
    if "$SU_CMD" -c "dumpsys window windows" | grep -i 'mCurrentFocus' | grep -q 'com.asepv2.mobu'; then
        echo "[$TIMESTAMP] OK: Roblox (Mobu) sedang dimainkan."
    else
        echo "[$TIMESTAMP] ACTION: Roblox tidak di layar. Melakukan auto-join..."
        
        # 2. Kill paksa aplikasi Mod
        "$SU_CMD" -c "am force-stop com.asepv2.mobu"
        
        # 3. Start aplikasi Mod dengan target spesifik (-p)
        # Kita tambah '-p com.asepv2.mobu' biar sistem gak bingung
        "$SU_CMD" -c "am start --user 0 -a android.intent.action.VIEW -p com.asepv2.mobu -d 'roblox://placeId=121864768012064&linkCode=29945061429931940452490641554963'"
        
        sleep 20
    fi
    sleep 5
done
