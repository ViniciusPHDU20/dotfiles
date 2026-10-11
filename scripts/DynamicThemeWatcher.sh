#!/usr/bin/env bash
# ==============================================================================
# DynamicThemeWatcher - Listens for Noctalia wallpaper palette changes
# and triggers DynamicThemeSync to update Hyprland borders in real-time.
# ==============================================================================
set -euo pipefail

KITTY_THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/themes"
KITTY_THEME="${KITTY_THEME_DIR}/noctalia.conf"
SYNC_SCRIPT="${HOME}/dotfiles/scripts/DynamicThemeSync.sh"

mkdir -p "$KITTY_THEME_DIR"
[ -f "$KITTY_THEME" ] || touch "$KITTY_THEME"

# Initial sync
"$SYNC_SCRIPT" || true

# Watch for file modifications
while inotifywait -q -e close_write,create "$KITTY_THEME"; do
    sleep 0.1
    "$SYNC_SCRIPT" || true
done
