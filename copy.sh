#!/usr/bin/env bash
set -Eeuo pipefail

# Installs only specific configuration files from the repository.
# Run from any directory; the repository path is determined by the location of this script.

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr_dotfiles-backup-${TIMESTAMP}"

# Verify all source files before making any system changes.
REQUIRED_FILES=(
    "hypr/hyprland.lua"
    "waybar/config.jsonc"
    "waybar/style.css"
    "dunst/dunstrc"
    "kitty/kitty.conf"
    "kitty/current-theme.conf"
    "gtk/settings.ini"
    "gtk/gtk.css"
    "gtk/colors.css"
    "rofi/config.rasi"
    "starship/starship.toml"
    "thunar/uca.xml"
    "zshrc"
    "sddm/sugar-candy-theme.conf"
)

for relative_path in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$REPO_DIR/$relative_path" ]]; then
        printf 'Error: missing file in repository: %s\n' "$relative_path" >&2
        exit 1
    fi
done

backup_user_file() {
    local target="$1"
    local relative_path backup_path

    relative_path="${target#"$HOME"/}"
    backup_path="$BACKUP_DIR/$relative_path"
    mkdir -p -- "$(dirname -- "$backup_path")"
    cp -a -- "$target" "$backup_path"
    printf 'Backup: %s -> %s\n' "$target" "$backup_path"
}

copy_user_file() {
    local source_relative="$1"
    local target="$2"
    local source="$REPO_DIR/$source_relative"

    # Do not overwrite a directory if it accidentally exists at the target path instead of a file.
    if [[ -d "$target" && ! -L "$target" ]]; then
        printf 'Error: target path is a directory, not a file: %s\n' "$target" >&2
        return 1
    fi

    mkdir -p -- "$(dirname -- "$target")"

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -f "$target" && ! -L "$target" ]] && cmp -s -- "$source" "$target"; then
            printf 'Unchanged: %s\n' "$target"
            return 0
        fi

        backup_user_file "$target"
        rm -f -- "$target"
    fi

    install -m 644 -- "$source" "$target"
    printf 'Copied: %s -> %s\n' "$source_relative" "$target"
}

copy_system_file() {
    local source_relative="$1"
    local target="$2"
    local source="$REPO_DIR/$source_relative"

    if sudo test -d "$target" && ! sudo test -L "$target"; then
        printf 'Error: system target path is a directory, not a file: %s\n' "$target" >&2
        return 1
    fi

    if sudo test -e "$target" || sudo test -L "$target"; then
        if sudo test -f "$target" && sudo cmp -s -- "$source" "$target"; then
            printf 'Unchanged: %s\n' "$target"
            return 0
        fi

        # Keep the original SDDM configuration next to the file as a backup.
        sudo cp -a -- "$target" "${target}.bak-${TIMESTAMP}"
        sudo rm -f -- "$target"
        printf 'SDDM backup: %s.bak-%s\n' "$target" "$TIMESTAMP"
    fi

    sudo install -D -m 644 -- "$source" "$target"
    printf 'Copied: %s -> %s\n' "$source_relative" "$target"
}

printf 'Source repository: %s\n' "$REPO_DIR"
printf 'User backups (if any): %s\n\n' "$BACKUP_DIR"

# Hyprland: only the Lua configuration is copied; hyprland.conf is not used.
copy_user_file "hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"

# Waybar: both configurations are needed for the panel's look and layout.
copy_user_file "waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
copy_user_file "waybar/style.css" "$HOME/.config/waybar/style.css"

# Other user applications.
copy_user_file "dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
copy_user_file "kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
copy_user_file "kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
copy_user_file "gtk/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
copy_user_file "gtk/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
copy_user_file "gtk/colors.css" "$HOME/.config/gtk-3.0/colors.css"
copy_user_file "rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
copy_user_file "starship/starship.toml" "$HOME/.config/starship.toml"
copy_user_file "thunar/uca.xml" "$HOME/.config/Thunar/uca.xml"
copy_user_file "zshrc" "$HOME/.zshrc"

# System configuration for the Sugar-Candy theme for SDDM.
copy_system_file "sddm/sugar-candy-theme.conf" \
    "/usr/share/sddm/themes/sugar-candy/theme.conf"

printf '\nDone.\n'
