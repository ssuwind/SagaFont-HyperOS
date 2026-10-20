#!/system/bin/sh
MODDIR=${0%/*}
BACKUP_DIR="$MODDIR/theme_backup"
[ -d "$BACKUP_DIR" ] || exit 0

restore_one() {
  bak="$1"
  rel="${bak#$BACKUP_DIR/}"
  [ -n "$rel" ] || return
  dest="/$rel"
  case "$dest" in
    /data/system/theme/*|/data/system/theme_magic/*|/data/misc/theme/*|/data/user/0/com.android.thememanager/*)
      ;;
    *)
      return
      ;;
  esac
  dest_dir="$(dirname "$dest")"
  [ -d "$dest_dir" ] || return
  cp -f "$bak" "$dest"
  chmod 644 "$dest" 2>/dev/null
  restorecon -F "$dest" 2>/dev/null
}

find "$BACKUP_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | while IFS= read -r bak; do
  [ -f "$bak" ] || continue
  restore_one "$bak"
done
