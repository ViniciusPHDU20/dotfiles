#!/usr/bin/env bash
# ==============================================================================
# DynamicThemeWatcher - Watches Noctalia theme output and syncs Hyprland & Kitty
# Zero-reload, zero-crash, purely reactive IPC updates.
# ==============================================================================
THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/themes"
THEME_FILE="$THEME_DIR/noctalia.conf"
SYNC_SCRIPT="$HOME/dotfiles/scripts/DynamicThemeSync.sh"

# Ensure dir and file exist
mkdir -p "$THEME_DIR"
touch "$THEME_FILE"

# Initial synchronization
"$SYNC_SCRIPT" || true

# Continuous monitor loop
inotifywait -m -q -e close_write,moved_to --format "%f" "$THEME_DIR" 2>/dev/null | while read -r file; do
    if [ "$file" = "noctalia.conf" ]; then
        # Slight debounce for rapid writes
        sleep 0.1
        "$SYNC_SCRIPT" || true
    fi
done
