#!/system/bin/sh
MODDIR=${0%/*}
sleep 32

MODPATH="$MODDIR"
. "$MODPATH/lang/lang.sh"

su -lp 2000 -c "cmd notification post -S bigtext -t '$NOTIFY_TITLE' '$NOTIFY_TAG' '$NOTIFY_BODY'"

find /data/user/0/com.dragon.read/files/font -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
find /data/user/0/com.qidian.QDReader/files/truetype_fonts -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
