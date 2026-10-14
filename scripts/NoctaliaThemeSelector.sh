#!/usr/bin/env bash
# ==============================================================================
# NoctaliaThemeSelector - Interactive Preset & Style Switcher for Noctalia Shell
# Port of JaKooLit theme system to native Noctalia Wayland architecture.
# ==============================================================================
set -euo pipefail

PRESETS_DIR="${HOME}/dotfiles/config/noctalia/presets"
TARGET_CONFIG="${HOME}/dotfiles/config/noctalia/config.toml"
USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/config.toml"
WALLPAPERS_DIR="${HOME}/dotfiles/wallpapers"
SYNC_SCRIPT="${HOME}/dotfiles/scripts/DynamicThemeSync.sh"

if [ ! -d "$PRESETS_DIR" ]; then
    echo "Erro: Diretório de presets não encontrado em $PRESETS_DIR" >&2
    exit 1
fi

# Detect current preset by md5 / content comparison
current_preset=""
if [ -f "$TARGET_CONFIG" ]; then
    current_hash=$(md5sum "$TARGET_CONFIG" | awk '{print $1}')
    for p in "$PRESETS_DIR"/*.toml; do
        if [ "$(md5sum "$p" | awk '{print $1}')" = "$current_hash" ]; then
            current_preset=$(basename "$p" .toml)
            break
        fi
    done
fi

# Build menu list
options=()
for p in "$PRESETS_DIR"/*.toml; do
    name=$(basename "$p" .toml)
    if [ "$name" = "$current_preset" ]; then
        options+=("👉 $name (Ativo)")
    else
        options+=("   $name")
    fi
done

# Launch Noctalia dmenu
chosen=$(printf '%s\n' "${options[@]}" | noctalia dmenu -p "󰏘 Selecionar Tema do Noctalia" || true)

# Exit if cancelled
if [ -z "$chosen" ]; then
    exit 0
fi

# Clean selection name
clean_name=$(echo "$chosen" | sed 's/^[[:space:]]*//; s/^👉[[:space:]]*//; s/[[:space:]]*(Ativo)//')
selected_file="$PRESETS_DIR/${clean_name}.toml"

if [ ! -f "$selected_file" ]; then
    echo "Preset não encontrado: $selected_file" >&2
    exit 1
fi

# Apply preset to both dotfiles and active user config
cp -f "$selected_file" "$TARGET_CONFIG"
cp -f "$selected_file" "$USER_CONFIG"

# Map signature wallpaper for each preset
sig_wall=""
case "$clean_name" in
    "Kool-Catppuccin-Mocha")
        sig_wall="$WALLPAPERS_DIR/Pastel-Window.png"
        [ ! -f "$sig_wall" ] && sig_wall="$WALLPAPERS_DIR/Purple-sea-moon-stars.png"
        ;;
    "Kool-Cyberpunk-Neon")
        sig_wall="$WALLPAPERS_DIR/Night_City.png"
        [ ! -f "$sig_wall" ] && sig_wall="$WALLPAPERS_DIR/Night-City.jpg"
        ;;
    "Kool-Tokyo-Night")
        sig_wall="$WALLPAPERS_DIR/Tokyo_Pink.png"
        ;;
    "Kool-Nord-Frost")
        sig_wall="$WALLPAPERS_DIR/Northern Lights3.png"
        ;;
    "Kool-Gruvbox-Retro")
        sig_wall="$WALLPAPERS_DIR/Retro - Programmer.jpeg"
        ;;
    "Kool-Everforest")
        sig_wall="$WALLPAPERS_DIR/Fog-Forest-Everforest.png"
        ;;
    "Kool-Camellia-Islands")
        sig_wall="$WALLPAPERS_DIR/River-Moutains-Cherry-Blosums.png"
        ;;
    "Kool-Sleek-FullWidth")
        sig_wall="$WALLPAPERS_DIR/Lowpoly_Street.png"
        ;;
    "Kool-Crystal-Glass")
        sig_wall="$WALLPAPERS_DIR/Space-Nebula.png"
        ;;
    "Nordic-Slate")
        sig_wall="$WALLPAPERS_DIR/Dark_Nature.png"
        ;;
esac

# Switch wallpaper if signature wallpaper exists
if [ -n "$sig_wall" ] && [ -f "$sig_wall" ] && command -v noctalia >/dev/null 2>&1; then
    noctalia msg wallpaper-set "$sig_wall" >/dev/null 2>&1 || true
fi

# Small delay to let wallpaper and config hot-reload settle
sleep 0.3

# Re-apply theme templates and Hyprland dynamic border sync
if command -v noctalia >/dev/null 2>&1; then
    noctalia msg templates-apply >/dev/null 2>&1 || true
    noctalia msg notification-show "Tema Aplicado" "Estilo alterado para: ${clean_name}" >/dev/null 2>&1 || true
fi

if [ -f "$SYNC_SCRIPT" ]; then
    bash "$SYNC_SCRIPT" >/dev/null 2>&1 || true
fi

echo "Tema ${clean_name} aplicado com sucesso."
