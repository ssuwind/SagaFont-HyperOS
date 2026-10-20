#!/system/bin/sh
. "$MODPATH/lang/lang.sh"

ui_print "$SEARCH_FONTS"

SRC_FONT_XML="$MODPATH/fonts.xml"
FONTS_LIST="$MODPATH/fonts_list.yaml"

[ ! -f "$SRC_FONT_XML" ] && { ui_print "$ERR_NO_FONTS_XML"; abort "$ERR_NO_FONTS_XML"; }
[ ! -d "$MODPATH/system" ] && { ui_print "$ERR_NO_SYSTEM_DIR"; abort "$ERR_NO_SYSTEM_DIR"; }
[ ! -f "$FONTS_LIST" ] && { ui_print "$ERR_NO_FONTS_LIST"; abort "$ERR_NO_FONTS_LIST"; }

get_list() {
  sed -n "/^[[:space:]]*fallback:/,/^[^[:space:]]/p" "$FONTS_LIST" | sed -n "/^[[:space:]]\\{2\\}$1:/,/^[[:space:]]\\{2\\}[a-zA-Z_][a-zA-Z_]*:/p" | sed 's/#.*$//' | sed -n 's/^[[:space:]]*-[[:space:]]*//p'
}

FALLBACK_WHITELIST="$(get_list 'whitelist')"
FALLBACK_BLACKLIST="$(get_list 'blacklist')"
FALLBACK_REVERSE="$(get_list 'reverse')"

is_blacklisted() {
  local fname="$1"
  for blk in $FALLBACK_BLACKLIST; do
    [ "$fname" = "$blk" ] && return 0
  done
  return 1
}

is_whitelisted() {
  local fname="$1"
  for wl in $FALLBACK_WHITELIST; do
    [ "$fname" = "$wl" ] && return 0
  done
  return 1
}

is_reversed() {
  local fname="$1"
  for rv in $FALLBACK_REVERSE; do
    [ "$fname" = "$rv" ] && return 0
  done
  return 1
}

PROCESSED_FILES=""

handle_file() {
  local FILE_PATH="$1"
  local MOD_SUBDIR="$2"
  local FILE_NAME
  FILE_NAME="$(basename "$FILE_PATH")"

  [ ! -f "$FILE_PATH" ] && return

  for pf in $PROCESSED_FILES; do
    [ "$pf" = "$FILE_PATH" ] && return
  done

  ui_print "$FOUND_FONT $FILE_NAME"

  if is_blacklisted "$FILE_NAME"; then
    ui_print "$FONT_BLOCKED $FILE_NAME"
    PROCESSED_FILES="$PROCESSED_FILES $FILE_PATH"
    return
  fi

  mkdir -p "$MODPATH/$MOD_SUBDIR"
  local SRC
  if is_reversed "$FILE_NAME" && [ -f "$MODPATH/$FILE_NAME" ]; then
    SRC="$MODPATH/$FILE_NAME"
    ui_print "$FONT_REVERSE $FILE_NAME"
  else
    SRC="$SRC_FONT_XML"
  fi

  cp -f "$SRC" "$MODPATH/$MOD_SUBDIR/$FILE_NAME"

  if is_whitelisted "$FILE_NAME"; then
    ui_print "$FONT_ALLOWED $FILE_NAME"
  fi

  PROCESSED_FILES="$PROCESSED_FILES $FILE_PATH"
}

search_and_copy() {
  local SYS_DIR="$1"
  local MOD_SUBDIR="$2"

  for f in "$SYS_DIR"/font*.xml "$SYS_DIR"/fonts.xml; do
    [ ! -f "$f" ] && continue
    handle_file "$f" "$MOD_SUBDIR"
  done

  for wl in $FALLBACK_WHITELIST; do
    FILE_PATH="$SYS_DIR/$wl"
    [ ! -f "$FILE_PATH" ] && continue
    handle_file "$FILE_PATH" "$MOD_SUBDIR"
  done
}

HAS_INDEP_PRODUCT=0
HAS_INDEP_SYSTEM_EXT=0
HAS_INDEP_VENDOR=0
[ -d /product/etc ] && HAS_INDEP_PRODUCT=1
[ -d /system_ext/etc ] && HAS_INDEP_SYSTEM_EXT=1
[ -d /vendor/etc ] && HAS_INDEP_VENDOR=1

if [ -f /system/etc/fonts.xml ]; then
  mkdir -p "$MODPATH/system/etc"
  cp -f "$SRC_FONT_XML" "$MODPATH/system/etc/fonts.xml"
fi
if [ -f /system/etc/font_fallback.xml ]; then
  mkdir -p "$MODPATH/system/etc"
  cp -f "$SRC_FONT_XML" "$MODPATH/system/etc/font_fallback.xml"
fi

if [ "$HAS_INDEP_SYSTEM_EXT" -eq 1 ]; then
  search_and_copy "/system_ext/etc" "system_ext/etc"
else
  search_and_copy "/system/system_ext/etc" "system/system_ext/etc"
fi

if [ "$HAS_INDEP_PRODUCT" -eq 1 ]; then
  search_and_copy "/product/etc" "product/etc"
else
  search_and_copy "/system/product/etc" "system/product/etc"
fi

search_and_copy "/system/etc" "system/etc"

if [ "$HAS_INDEP_VENDOR" -eq 1 ]; then
  search_and_copy "/vendor/etc" "vendor/etc"
else
  search_and_copy "/system/vendor/etc" "system/vendor/etc"
fi

search_and_copy "/mi_ext/etc" "mi_ext/etc"
search_and_copy "/odm/etc" "odm/etc"

ui_print "$FONTS_DONE"
