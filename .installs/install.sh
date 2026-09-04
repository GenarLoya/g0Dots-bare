#!/bin/bash

# ============================================
# g0Dots Installer
# ============================================

set -e

DOTFILES_URL="https://github.com/GenarLoya/g0Dots-bare.git"
DOTFILES="$HOME/.dotfiles"
LOCAL_BIN="$HOME/.local/bin"
INSTALLS="$HOME/.installs"

echo "=========================================="
echo "  g0Dots Installer"
echo "=========================================="
echo ""

# -------------------------
# 1. Verificar paru
# -------------------------
if ! command -v paru &> /dev/null; then
    echo "⚠️  paru no está instalado."
    read -p "¿Quieres instalarlo? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Saliendo..."
        exit 1
    fi
    echo "📦 Instalando paru..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si
    cd ~
fi

# -------------------------
# 2. Instalar dependencias
# -------------------------
echo ""
echo "📦 Instalando dependencias..."

paru -S --sudoloop - < <(cat << 'EOF'
hyprland
waybar
rofi
fish
ghostty
awww
fastfetch
micro
starship
playerctl
brightnessctl
wireplumber
polkit-gnome
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
xdg-utils
EOF
)

# -------------------------
# 3. Clonar dotfiles si no existen
# -------------------------
if [ ! -d "$DOTFILES" ]; then
    echo ""
    echo "📁 Clonando dotfiles..."
    git clone --bare "$DOTFILES_URL" "$DOTFILES"
    git --git-dir="$DOTFILES" --work-tree="$HOME" checkout 2>&1 || true
    git --git-dir="$DOTFILES" --work-tree="$HOME" checkout main 2>&1 || git --git-dir="$DOTFILES" --work-tree="$HOME" checkout master 2>&1 || true
    git --git-dir="$DOTFILES" config --local status.showUntrackedFiles no
fi

# -------------------------
# 4. Crear ~/.local/bin y dot alias
# -------------------------
echo ""
echo "🔗 Creando alias 'dot'..."

mkdir -p "$LOCAL_BIN"

cat > "$LOCAL_BIN/dot" << 'DOTEOF'
#!/bin/bash
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
DOTEOF

chmod +x "$LOCAL_BIN/dot"

# Agregar al PATH si no está
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.config/fish/config.fish"
fi

# -------------------------
# 5. Configuraciones extras
# -------------------------
echo ""
echo "⚙️  Configuraciones..."

echo ""
echo "=========================================="
echo "  ✅ Instalación completa!"
echo "=========================================="
echo ""
echo "Ejecuta para recargar shell:"
echo "  source ~/.bashrc  # bash"
echo "  source ~/.config/fish/config.fish  # fish"
echo ""
echo "Comandos dotfiles:"
echo "  dot status   # ver estado"
echo "  dot add      # agregar archivos"
echo "  dot commit   # guardar cambios"
echo "  dot push     # subir cambios"
echo ""
