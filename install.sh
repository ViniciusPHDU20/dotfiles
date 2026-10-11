#!/usr/bin/env bash
# ==============================================================================
# SnyX Dotfiles Installer
# Environment: Arch / CachyOS (Zen 5 x86-64-v4) - Hyprland & Noctalia
# ==============================================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config.bak-$(date +%Y%m%d_%H%M%S)"

echo "==> Iniciando sincronização do SnyX Dotfiles..."

# Criar backup antes de symlinkar
mkdir -p "$BACKUP_DIR"

link_config() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  [Backup] Movendo $dest existente para $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    echo "  [Symlink] $src -> $dest"
    ln -sfn "$src" "$dest"
}

# Criar diretórios base
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/wallpapers"

# Linkar configurações principais
link_config "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
link_config "$DOTFILES_DIR/config/noctalia" "$HOME/.config/noctalia"
link_config "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
link_config "$DOTFILES_DIR/config/fish" "$HOME/.config/fish"
link_config "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
link_config "$DOTFILES_DIR/config/quickshell" "$HOME/.config/quickshell"

# Linkar wallpapers
ln -sfn "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/wallpapers" 2>/dev/null || true

echo "==> Concluído com sucesso! O ambiente agora está sincronizado via symlinks."
