#!/system/bin/sh
MODDIR=${0%/*}
SAGA_MAIN="$MODDIR/system/fonts/SagaSans.ttf"
[ -f "$SAGA_MAIN" ] || SAGA_MAIN="$MODDIR/product/fonts/SagaSans.ttf"
[ -f "$SAGA_MAIN" ] || exit 0
[ -f "$MODDIR/hyperos_cover.sh" ] || exit 0
. "$MODDIR/hyperos_cover.sh"
SAGA_BACKUP_DIR="$MODDIR/theme_backup"
cover_hyperos_runtime "$SAGA_MAIN"
