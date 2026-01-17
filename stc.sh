
while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    
    if su -c "dumpsys window windows | grep -i 'mCurrentFocus' | grep -q 'com.roblox.client'"; then
        echo "[$TIMESTAMP] OK: Roblox sedang dimainkan."
    else
        echo "[$TIMESTAMP] ACTION: Roblox tidak di layar. Melakukan auto-join..."
        su -c "am force-stop com.roblox.client" > /dev/null 2>&1
        su -c "am start --user 0 -a android.intent.action.VIEW -d 'roblox://placeId=121864768012064&linkCode=29945061429931940452490641554963'" > /dev/null 2>&1
        sleep 20
    fi
    sleep 5
done
