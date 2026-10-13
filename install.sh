#!/usr/bin/env bash

# Zastavit skript při jakékoliv chybě
set -e

echo "=========================================="
echo "    Hyprland Dotfiles Installer           "
echo "=========================================="

# 1. Zeptat se na cílový home adresář
read -p "Zadejte cestu k cílovému home adresáři [výchozí: $HOME]: " TARGET_HOME
TARGET_HOME="${TARGET_HOME:-$HOME}"

if [ ! -d "$TARGET_HOME" ]; then
    echo "Chyba: Zadaný adresář '$TARGET_HOME' neexistuje!"
    exit 1
fi

# 2. Zeptat se na režim instalace (symlink vs. kopie)
read -p "Chcete konfigy symlinkovat (s) nebo zkopírovat (k)? [s/k]: " INSTALL_MODE

# Zjistit aktuální adresář, kde se skript (a repozitář) nachází
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG="$TARGET_HOME/.config"

# Ujistit se, že cílová složka .config existuje
mkdir -p "$TARGET_CONFIG"

echo "------------------------------------------"
echo "Zdrojový repozitář: $REPO_DIR"
echo "Cílová složka:      $TARGET_CONFIG"
echo "------------------------------------------"

# 3. Projít položky v repozitáři
for item in "$REPO_DIR"/*; do
    item_name=$(basename "$item")
    
    # Ignorovat instalační skript, git složku a dokumentaci
    if [[ "$item_name" == "install.sh" || "$item_name" == ".git" || "$item_name" == "README.md" || "$item_name" == ".gitignore" ]]; then
        continue
    fi

    # Pracujeme se složkami, které patří do .config (např. hypr, waybar, kitty...)
    if [ -d "$item" ]; then
        dest_path="$TARGET_CONFIG/$item_name"
        
        # Pokud už cíl existuje, vytvoříme jeho zálohu
        if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
            echo "Zálohuji existující $dest_path na ${dest_path}.bak"
            rm -rf "${dest_path}.bak"
            mv "$dest_path" "${dest_path}.bak"
        fi

        if [[ "$INSTALL_MODE" == "k" || "$INSTALL_MODE" == "K" ]]; then
            echo "Kopíruji $item_name -> $dest_path"
            cp -r "$item" "$dest_path"
        else
            echo "Vytvářím symlink $item_name -> $dest_path"
            ln -sfn "$item" "$dest_path"
        fi
    fi
done

echo "------------------------------------------"
echo "✅ Instalace dotfiles proběhla úspěšně!"
echo "Nyní stačí restartovat Hyprland nebo se znovu přihlásit."
