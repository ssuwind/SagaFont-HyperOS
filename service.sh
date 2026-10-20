#!/system/bin/sh
MODDIR=${0%/*}
sleep 32

MODPATH="$MODDIR"
. "$MODPATH/lang/lang.sh"

# 发送开机通知
su -lp 2000 -c "cmd notification post -S bigtext -t '$NOTIFY_TITLE' '$NOTIFY_TAG' '$NOTIFY_BODY'"

if [ -f "$MODDIR/hyperos_cover.sh" ]; then
  . "$MODDIR/hyperos_cover.sh"
  SAGA_MAIN="$MODDIR/system/fonts/SagaSans.ttf"
  [ -f "$SAGA_MAIN" ] || SAGA_MAIN="$MODDIR/product/fonts/SagaSans.ttf"
  if [ -f "$SAGA_MAIN" ]; then
    SAGA_BACKUP_DIR="$MODDIR/theme_backup"
    disable_hyperos_font_overlay
    cover_hyperos_runtime "$SAGA_MAIN"
    sleep 8
    cover_hyperos_runtime "$SAGA_MAIN"
  fi
fi

# 取消部分APP内置字体权限
find /data/user/0/com.dragon.read/files/font -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
find /data/user/0/com.qidian.QDReader/files/truetype_fonts -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec chmod 000 {} \;
