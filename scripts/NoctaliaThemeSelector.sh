#!/usr/bin/env bash
# ==============================================================================
# NoctaliaThemeSelector - Interactive Preset & Style Switcher for Noctalia Shell
# Port of JaKooLit theme system to native Noctalia Wayland architecture.
# ==============================================================================
set -euo pipefail

PRESETS_DIR="${HOME}/dotfiles/config/noctalia/presets"
TARGET_CONFIG="${HOME}/dotfiles/config/noctalia/config.toml"
USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/config.toml"
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

# Apply preset
cp -f "$selected_file" "$TARGET_CONFIG"

# If ~/.config/noctalia/config.toml is a separate file or symlink, ensure it stays synced
if [ -f "$USER_CONFIG" ] && [ ! "$USER_CONFIG" -ef "$TARGET_CONFIG" ]; then
    cp -f "$selected_file" "$USER_CONFIG"
fi

# Re-apply theme templates and Hyprland dynamic border sync
sleep 0.2
if command -v noctalia >/dev/null 2>&1; then
    noctalia msg templates-apply >/dev/null 2>&1 || true
    noctalia msg notification-show "Tema do Noctalia" "Estilo aplicado: ${clean_name}" >/dev/null 2>&1 || true
fi

if [ -f "$SYNC_SCRIPT" ]; then
    bash "$SYNC_SCRIPT" >/dev/null 2>&1 || true
fi

echo "Tema ${clean_name} aplicado com sucesso."
