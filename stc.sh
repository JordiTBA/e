# Cari lokasi su otomatis
SU_CMD=$(which su)

while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    
    # PERUBAHAN DI SINI:
    # 1. Ganti 'dumpsys window windows' jadi 'dumpsys activity activities'
    # 2. Ganti grep 'mCurrentFocus' jadi 'mResumedActivity'
    # Ini bakal mendeteksi app walaupun di mode Freeform/Floating
    if "$SU_CMD" -c "dumpsys activity activities" | grep -i 'mResumedActivity' | grep -q 'com.asepv2.mobu'; then
        echo "[$TIMESTAMP] OK: Roblox (Mobu) aktif (Freeform/Fullscreen)."
    else
        echo "[$TIMESTAMP] ACTION: Roblox tidak terdeteksi. Melakukan auto-join..."
        
        # Kill app
        "$SU_CMD" -c "am force-stop com.asepv2.mobu"
        
        # Start app (tetap pakai -p biar aman)
        "$SU_CMD" -c "am start --user 0 -a android.intent.action.VIEW -p com.asepv2.mobu -d 'roblox://placeId=121864768012064&linkCode=29945061429931940452490641554963'"
        
        # Waktu tunggu loading (sesuaikan kalau HP lambat)
        sleep 20
    fi
    sleep 5
done
