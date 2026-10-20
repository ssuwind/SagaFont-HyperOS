#!/system/bin/sh
MODDIR=${0%/*}
sleep 32

MODPATH="$MODDIR"
. "$MODPATH/lang/lang.sh"

su -lp 2000 -c "cmd notification post -S bigtext -t '$NOTIFY_TITLE' '$NOTIFY_TAG' '$NOTIFY_BODY'"

if [ -f "$MODDIR/hyperos_cover.sh" ]; then
  . "$MODDIR/hyperos_cover.sh"
  SAGA_MAIN="$MODDIR/system/fonts/SagaSans.ttf"
  [ -f "$SAGA_MAIN" ] || SAGA_MAIN="$MODDIR/product/fonts/SagaSans.ttf"
  if [ -f "$SAGA_MAIN" ]; then
    SAGA_BACKUP_DIR="$MODDIR/theme_backup"
    cover_theme_runtime "$SAGA_MAIN"
    cover_app_runtime "$SAGA_MAIN"
    sleep 12
    cover_theme_runtime "$SAGA_MAIN"
    cover_app_runtime "$SAGA_MAIN"
  fi
fi

find /data/user/0/com.dragon.read/files/font -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
find /data/user/0/com.qidian.QDReader/files/truetype_fonts -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
