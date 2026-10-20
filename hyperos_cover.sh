#!/system/bin/sh

place_saga() {
  src="$1"
  dest="$2"
  [ -f "$src" ] || return 1
  dest_dir="$(dirname "$dest")"
  [ -d "$dest_dir" ] || mkdir -p "$dest_dir"
  [ "$src" = "$dest" ] && return 0
  if ln -f "$src" "$dest" 2>/dev/null; then
    return 0
  fi
  if [ -n "$SAGA_COPY_ANCHOR" ] && [ -f "$SAGA_COPY_ANCHOR" ]; then
    ln -f "$SAGA_COPY_ANCHOR" "$dest" 2>/dev/null && return 0
  fi
  cp -f "$src" "$dest" || return 1
  chmod 644 "$dest" 2>/dev/null
  restorecon -F "$dest" 2>/dev/null
  SAGA_COPY_ANCHOR="$dest"
  return 0
}

cover_one() {
  src="$1"
  dest="$2"
  [ -f "$src" ] || return
  [ -f "$dest" ] || return
  dest_dir="$(dirname "$dest")"
  [ -d "$dest_dir" ] || return
  src_size=$(wc -c < "$src" 2>/dev/null | tr -d ' ')
  dest_size=$(wc -c < "$dest" 2>/dev/null | tr -d ' ')
  [ -n "$src_size" ] && [ "$src_size" = "$dest_size" ] && return
  if [ -n "$SAGA_BACKUP_DIR" ]; then
    rel="${dest#/}"
    bak="$SAGA_BACKUP_DIR/$rel"
    if [ ! -f "$bak" ]; then
      mkdir -p "$(dirname "$bak")"
      cp -f "$dest" "$bak"
    fi
  fi
  cp -f "$src" "$dest"
  chmod 644 "$dest" 2>/dev/null
  restorecon -F "$dest" 2>/dev/null
}

skip_hyperos_font() {
  name="$1"
  case "$name" in
    *.ttc|*.TTC)
      return 0 ;;
    MFGA*|Plangothic*|Unicode1*|Unicode2*|Unicode3*|Braille*|Private-Use*|Unicodia*|Unknown-symbol*|ZUno*|Satisar*|Tibetan-Regular*|Archaic*|DroidSansMono*|TH-Tshyn*|P1-Regular*|P2-Regular*|P3-Regular*|SagaSans*)
      return 0 ;;
  esac
  return 1
}

is_hyperos_ui_font() {
  name="$1"
  case "$name" in
    MiSans*|MiLan*|MILan*|MiClock*|Mitype*|MiType*|MiSerif*|MiuiEx*|Miui-*|MIUI*|Roboto*|RobotoFlex*|Qinghe*|Neumatic*|SilkSerif*|Bebas*|MoreClock*|LockClock*|HyperOS*|hyperos*|clock_num*|ClockNum*|MiSansC*|ClockTypeface*|ClockFont*|clock*.ttf|clock*.otf|Clock*.ttf|Clock*.otf|*Emoji*|NotoColorEmoji*|NotoSansSymbols*)
      return 0 ;;
  esac
  return 1
}

cover_theme_dir() {
  src="$1"
  dir="$2"
  [ -d "$dir" ] || return
  for f in "$dir"/*.ttf "$dir"/*.otf; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    skip_hyperos_font "$name" && continue
    is_hyperos_ui_font "$name" || continue
    cover_one "$src" "$f"
  done
}

disable_hyperos_font_overlay() {
  command -v cmd >/dev/null 2>&1 || return
  cmd overlay list 2>/dev/null | while IFS= read -r line; do
    pkg="${line##* }"
    [ -n "$pkg" ] || continue
    case "$pkg" in
      com.android.theme.font.*|com.android.theme.fonts.*|*.thememanager.font*|*.theme.font.*)
        cmd overlay disable --user 0 "$pkg" >/dev/null 2>&1
        ;;
    esac
  done
}

cover_hyperos_runtime() {
  saga="$1"
  [ -f "$saga" ] || return

  cover_theme_dir "$saga" /data/system/theme/fonts
  cover_theme_dir "$saga" /data/system/theme_magic/fonts
  cover_theme_dir "$saga" /data/system/theme
  cover_theme_dir "$saga" /data/system/theme_magic
  cover_theme_dir "$saga" /data/misc/theme/fonts
  cover_theme_dir "$saga" /data/user/0/com.android.thememanager/files/fonts
  cover_theme_dir "$saga" /data/user/0/com.android.thememanager/files/MIUI/theme/fonts

  for extra in \
    /data/system/theme/clock \
    /data/system/theme/lockscreen \
    /data/system/theme/aod \
    /data/system/theme_magic/clock \
    /data/system/theme_magic/lockscreen \
    /data/system/theme_magic/aod
  do
    [ -d "$extra" ] || continue
    cover_theme_dir "$saga" "$extra"
  done
}
