SKIPUNZIP=0
. "$MODPATH/lang/lang.sh"

version_check() {
  if [ -d /data/adb/ksu ]; then
    if [ -z "$KSU_VER_CODE" ] || [ -z "$KSU_KERNEL_VER_CODE" ]; then
      ui_print "$(msg KSUV_NOFOUND)"
    elif [ "$KSU_VER_CODE" -lt 11986 ] || [ "$KSU_KERNEL_VER_CODE" -lt 11986 ]; then
      ui_print "$(msg KSU_LOW)"
      abort
    fi

  elif [ -d /data/adb/magisk ]; then
    if [ -z "$MAGISK_VER_CODE" ]; then
      ui_print "$(msg MAGISKV_NOFOUND)"
    elif [ "$MAGISK_VER_CODE" -lt 28000 ]; then
      ui_print "$(msg MAGISK_LOW)"
      abort
    fi
  fi
}
version_check

if [ "$API" -le 32 ]; then
  ui_print "$(msg ANDROID_12_OR_LOWER)"
  mv -f "$MODPATH/system/fonts/NotoColorEmoji-fallback.ttf" "$MODPATH/system/fonts/NotoColorEmoji.ttf"
else
  ui_print "$(msg ANDROID_13_OR_HIGHER)"
  rm -f "$MODPATH/system/fonts/NotoColorEmoji-fallback.ttf"
fi

if [ -d "/data/adb/modules/playintegrityfix" ]; then
  [ -d "/data/adb/ksu" ] && ui_print "$(msg PIF_WARNING_KSU)" && ui_print "$(msg PIF_WARNING_KSU2)"
  [ -d "/data/adb/magisk" ] && ui_print "$(msg PIF_WARNING_MAGISK)"
fi

MFGA_OLD_ID="/data/adb/modules/Colorfontsproject"
[ -d "$MFGA_OLD_ID" ] && ui_print "$(msg MODULE_OBSOLETE)" && touch "$MFGA_OLD_ID/remove"

deleted_fonts=0
for f in /data/adb/modules/SagaFont/system/fonts/*.disabled; do
    [ -e "$f" ] && rm -f -- "$f" && deleted_fonts=1
done
[ "$deleted_fonts" -eq 1 ] && ui_print "$(msg FONT_BLOCK_DISABLED)"
deleted_backup=0
for f in /data/adb/modules/SagaFont/uni_backup/*.*; do
    [ -e "$f" ] && rm -f -- "$f" && deleted_backup=1
done
[ "$deleted_backup" -eq 1 ] && ui_print "$(msg UNI_BLOCK_DISABLED)"

MIUI_NAM=$(getprop ro.miui.ui.version.name)
MIOS_NAM=$(getprop ro.mi.os.version.name)
if [ -n "$MIUI_NAM" ] || [ -n "$MIOS_NAM" ]; then
  ui_print "$(msg XIAOMI_KEEP)"
  ui_print "$(msg OVERLAY_HINT)"
else
  ui_print "$(msg NON_XIAOMI_REMOVE)"
fi

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
  SAGA_COPY_ANCHOR="$dest"
  return 0
}

skip_font() {
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
    MiSans*|MiLan*|MILan*|MiClock*|Mitype*|MiType*|MiSerif*|MiuiEx*|Miui-*|MIUI*|Roboto*|RobotoFlex*|Qinghe*|MoreClock*|LockClock*|HyperOS*|hyperos*|clock_num*|ClockNum*|MiSansC*|ClockTypeface*|ClockFont*|clock*.ttf|clock*.otf|Clock*.ttf|Clock*.otf|SysFont*|SysSans*|*Emoji*|NotoColorEmoji*|NotoSansSymbols*)
      return 0 ;;
  esac
  return 1
}

SAGA_MAIN="$MODPATH/system/fonts/SagaSans.ttf"
if [ ! -f "$SAGA_MAIN" ]; then
  ui_print "[!] SagaSans.ttf not found in system/fonts"
  abort "[!] Missing SagaSans.ttf, refuse to install"
fi
SAGA_SIZE=$(wc -c < "$SAGA_MAIN" 2>/dev/null | tr -d ' ')
if [ -z "$SAGA_SIZE" ] || [ "$SAGA_SIZE" -lt 102400 ]; then
  ui_print "[!] SagaSans.ttf is empty or too small"
  abort "[!] Invalid SagaSans.ttf, refuse to install"
fi

ui_print "- Applying SagaSans to HyperOS system UI fonts..."
ROBOTO_EXTRA_NAMES="SysFont-Regular.ttf SysSans-En-Regular.ttf Roboto-Regular.ttf Roboto-Italic.ttf RobotoFlex-Regular.ttf Roboto-Thin.ttf Roboto-ThinItalic.ttf Roboto-Light.ttf Roboto-LightItalic.ttf Roboto-Medium.ttf Roboto-MediumItalic.ttf Roboto-Bold.ttf Roboto-BoldItalic.ttf Roboto-Black.ttf Roboto-BlackItalic.ttf RobotoCondensed-Regular.ttf RobotoCondensed-Bold.ttf RobotoCondensed-Light.ttf RobotoCondensed-Italic.ttf NotoSans-Regular.ttf NotoSans-Bold.ttf SourceSansPro-Regular.ttf GoogleSans-Regular.ttf GoogleSans-Medium.ttf GoogleSans-Bold.ttf ProductSans-Regular.ttf ProductSans-Bold.ttf"
for f in $ROBOTO_EXTRA_NAMES; do
  place_saga "$SAGA_MAIN" "$MODPATH/system/fonts/$f"
done

PRODUCT_FONT_SUBDIR=""
if [ -d /product/fonts ]; then
  PRODUCT_FONT_SUBDIR="product/fonts"
elif [ -d /system/product/fonts ]; then
  PRODUCT_FONT_SUBDIR="system/product/fonts"
fi
if [ -n "$PRODUCT_FONT_SUBDIR" ]; then
  place_saga "$SAGA_MAIN" "$MODPATH/$PRODUCT_FONT_SUBDIR/SagaSans.ttf"
fi

HAS_INDEP_PRODUCT=0
HAS_INDEP_SYSTEM_EXT=0
HAS_INDEP_VENDOR=0
[ -d /product/fonts ] && HAS_INDEP_PRODUCT=1
[ -d /system_ext/fonts ] && HAS_INDEP_SYSTEM_EXT=1
[ -d /vendor/fonts ] && HAS_INDEP_VENDOR=1

HYPEROS_FONT_NAMES="MiSans.ttf MiSans-Regular.ttf MiSansVF.ttf MiSansVF.otf MiSans_VF.ttf MiSansL3.otf MiSansLatinVF.ttf MiSansTCVF.ttf MiSansRoundedSC.ttf MiSansRoundedTC.ttf MiSansCondensed2T.ttf MiSansC.ttf MILanProVF.ttf MILanProVF-Medium.ttf MitypeVF.ttf MitypeClock.otf MitypeClockVF.ttf MitypeClockMono.otf MitypeMonoVF.ttf MiClock.ttf MiClockVF.ttf MiSerifSCVF.ttf MiSerifTCVF.ttf MiuiEx-Regular.ttf MiuiEx-Light.ttf MiuiEx-Bold.ttf MoreClock.otf Qinghe.otf ClockTypeface.otf ClockFont.ttf NotoColorEmoji.ttf NotoColorEmoji-fallback.ttf NotoColorEmojiLegacy.ttf NotoColorEmojiFlags.ttf NotoSansSymbols-Regular-Subsetted2.ttf MiSansArabic.ttf MiSansThai.ttf MiSansTibetan.ttf MiSansKhmer.ttf MiSansMyanmar.ttf MiSansLao.ttf"
for f in $HYPEROS_FONT_NAMES; do
  place_saga "$SAGA_MAIN" "$MODPATH/system/fonts/$f"
  if [ -n "$PRODUCT_FONT_SUBDIR" ]; then
    place_saga "$SAGA_MAIN" "$MODPATH/$PRODUCT_FONT_SUBDIR/$f"
  fi
done

FONT_SCAN_DIRS="/system/fonts /system/product/fonts /system/system_ext/fonts /system/vendor/fonts /vendor/fonts /product/fonts /system_ext/fonts /mi_ext/fonts /odm/fonts"
for dir in $FONT_SCAN_DIRS; do
  [ -d "$dir" ] || continue
  case "$dir" in
    /system/fonts) subdir="system/fonts" ;;
    /system/product/*)
      [ "$HAS_INDEP_PRODUCT" -eq 1 ] && continue
      subdir="system/product/${dir#/system/product/}" ;;
    /product/*) subdir="product/${dir#/product/}" ;;
    /system/system_ext/*)
      [ "$HAS_INDEP_SYSTEM_EXT" -eq 1 ] && continue
      subdir="system/system_ext/${dir#/system/system_ext/}" ;;
    /system_ext/*) subdir="system_ext/${dir#/system_ext/}" ;;
    /system/vendor/*)
      [ "$HAS_INDEP_VENDOR" -eq 1 ] && continue
      subdir="system/vendor/${dir#/system/vendor/}" ;;
    /vendor/*) subdir="vendor/${dir#/vendor/}" ;;
    /mi_ext/*) subdir="mi_ext/${dir#/mi_ext/}" ;;
    /odm/*) subdir="odm/${dir#/odm/}" ;;
    *) continue ;;
  esac
  [ -z "$subdir" ] && continue
  for f in "$dir"/*.ttf "$dir"/*.otf; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    skip_font "$name" && continue
    if is_hyperos_ui_font "$name"; then
      place_saga "$SAGA_MAIN" "$MODPATH/$subdir/$name"
      ui_print "- Covered: $name"
    fi
  done
done

parse_font_xml() {
  local xml="$1" subdir="$2"
  [ -f "$xml" ] || return
  grep -oE '[A-Za-z0-9_.-]+\.(ttf|otf)' "$xml" 2>/dev/null | sort -u | while IFS= read -r name; do
    name="$(basename "$name")"
    skip_font "$name" && continue
    if is_hyperos_ui_font "$name"; then
      place_saga "$SAGA_MAIN" "$MODPATH/$subdir/$name"
      ui_print "- Covered: $name"
    fi
  done
}

for dir in /system/etc /system/product/etc /system/system_ext/etc /system/vendor/etc /vendor/etc /product/etc /system_ext/etc /mi_ext/etc /odm/etc; do
  [ -d "$dir" ] || continue
  case "$dir" in
    /system/etc) subdir="system/fonts" ;;
    /system/product/*)
      [ "$HAS_INDEP_PRODUCT" -eq 1 ] && continue
      subdir="system/product/fonts" ;;
    /product/*) subdir="product/fonts" ;;
    /system/system_ext/*)
      [ "$HAS_INDEP_SYSTEM_EXT" -eq 1 ] && continue
      subdir="system/system_ext/fonts" ;;
    /system_ext/*) subdir="system_ext/fonts" ;;
    /system/vendor/*)
      [ "$HAS_INDEP_VENDOR" -eq 1 ] && continue
      subdir="system/vendor/fonts" ;;
    /vendor/*) subdir="vendor/fonts" ;;
    /mi_ext/*) subdir="mi_ext/fonts" ;;
    /odm/*) subdir="odm/fonts" ;;
    *) continue ;;
  esac
  parse_font_xml "$dir/fonts.xml" "$subdir"
  parse_font_xml "$dir/font_fallback.xml" "$subdir"
  parse_font_xml "$dir/fonts_fallback.xml" "$subdir"
done

. "$MODPATH/hyperos_cover.sh"
SAGA_BACKUP_DIR="$MODPATH/theme_backup"
cover_theme_runtime "$SAGA_MAIN"
cover_app_runtime "$SAGA_MAIN"

. "$MODPATH/search_dirs.sh"

if command -v set_perm_recursive >/dev/null 2>&1; then
  set_perm_recursive "$MODPATH/system/fonts" 0 0 0755 0644
  [ -d "$MODPATH/product/fonts" ] && set_perm_recursive "$MODPATH/product/fonts" 0 0 0755 0644
  [ -d "$MODPATH/system/product/fonts" ] && set_perm_recursive "$MODPATH/system/product/fonts" 0 0 0755 0644
  [ -d "$MODPATH/system/etc" ] && set_perm_recursive "$MODPATH/system/etc" 0 0 0755 0644
  [ -d "$MODPATH/product/etc" ] && set_perm_recursive "$MODPATH/product/etc" 0 0 0755 0644
fi

ui_print "- Welcome to SagaFont for HyperOS!"
ui_print "$(msg OVERLAY_HINT)"
