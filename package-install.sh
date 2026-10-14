#!/usr/bin/env bash
set -Eeuo pipefail

# Install packages listed in pkglist.txt and aur-pkglist.txt.
# Run this script as your normal user from the directory containing both files.

SCRIPT_NAME="${0##*/}"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/package-install"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_FILE="$LOG_DIR/install-$TIMESTAMP.log"

PACMAN_LIST="pkglist-pacman.txt"
AUR_LIST="pkglist-aur.txt"

PACMAN_PACKAGES=()
AUR_PACKAGES=()
FAILED_PACKAGES=()

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'status=$?; printf "\\nERROR: %s failed at line %s (exit status %s).\\nLog: %s\\n" "$SCRIPT_NAME" "$LINENO" "$status" "$LOG_FILE" >&2; exit "$status"' ERR

info()  { printf '\\n[INFO] %s\\n' "$*"; }
warn()  { printf '\\n[WARN] %s\\n' "$*" >&2; }
error() { printf '\\n[ERROR] %s\\n' "$*" >&2; }
have()  { command -v "$1" >/dev/null 2>&1; }

usage() {
    cat <<EOF
Usage: ./$SCRIPT_NAME

Run as a normal user in the directory containing:
  - $PACMAN_LIST  (official repository packages)
  - $AUR_LIST     (AUR packages)

The script checks dependencies, parses the package lists, synchronizes and
installs repository packages, installs AUR packages using yay, and writes a log.
EOF
}

cleanup_temp() {
    [[ -n "${TEMP_DIR:-}" && -d "${TEMP_DIR:-}" ]] && rm -rf -- "$TEMP_DIR"
}
trap cleanup_temp EXIT

if [[ "${EUID}" -eq 0 ]]; then
    error "Do not run this script as root. Run it as your normal user; sudo will be requested when needed."
    exit 1
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

for file in "$PACMAN_LIST" "$AUR_LIST"; do
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        error "Cannot read '$file'. Run this script from the directory containing both package list files."
        exit 1
    fi
done

if ! have pacman; then
    error "pacman was not found. This script is intended for Arch Linux and Arch-based systems."
    exit 1
fi

if ! have sudo; then
    error "'sudo' is required but was not found."
    exit 1
fi

if ! sudo -v; then
    error "Could not obtain sudo privileges."
    exit 1
fi

parse_list() {
    local file="$1"
    local output_name="$2"
    local -n output="$output_name"
    local line package
    declare -A seen=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove comments and surrounding whitespace.
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue

        # Package-list files should contain one package per line. Reject
        # unexpected shell-like content rather than evaluating it.
        if [[ "$line" =~ [[:space:]] ]]; then
            warn "Skipping malformed line in $file: $line"
            continue
        fi

        # Accept repository-qualified entries such as extra/firefox.
        package="${line##*/}"

        if [[ ! "$package" =~ ^[A-Za-z0-9@._+-]+$ ]]; then
            warn "Skipping invalid package name in $file: $line"
            continue
        fi

        if [[ -z "${seen[$package]+x}" ]]; then
            output+=("$package")
            seen["$package"]=1
        fi
    done < "$file"
}

parse_list "$PACMAN_LIST" PACMAN_PACKAGES
parse_list "$AUR_LIST" AUR_PACKAGES

if ((${#PACMAN_PACKAGES[@]} == 0 && ${#AUR_PACKAGES[@]} == 0)); then
    error "No valid package names were found in either list."
    exit 1
fi

info "Package installation log: $LOG_FILE"
printf 'Official repository packages: %d\\n' "${#PACMAN_PACKAGES[@]}"
printf 'AUR packages:                %d\\n' "${#AUR_PACKAGES[@]}"

if ((${#PACMAN_PACKAGES[@]} > 0)); then
    printf '\\nOfficial repository packages:\\n'
    printf '  %s\\n' "${PACMAN_PACKAGES[@]}"
fi
if ((${#AUR_PACKAGES[@]} > 0)); then
    printf '\\nAUR packages:\\n'
    printf '  %s\\n' "${AUR_PACKAGES[@]}"
fi

printf '\\n'
read -r -p "Continue with these package lists? Type INSTALL to continue: " confirmation
if [[ "$confirmation" != "INSTALL" ]]; then
    info "Cancelled. No packages were installed."
    exit 0
fi

# Ensure the base package metadata and installed system are kept in sync.
if ((${#PACMAN_PACKAGES[@]} > 0)); then
    info "Synchronizing package databases and installing official repository packages..."
    sudo pacman -Syu --needed -- "${PACMAN_PACKAGES[@]}"
else
    info "No official repository packages to install."
fi

if ((${#AUR_PACKAGES[@]} > 0)); then
    if ! have yay; then
        info "yay is not installed. Installing build prerequisites and building yay from the AUR..."

        sudo pacman -S --needed -- git base-devel

        TEMP_DIR="$(mktemp -d)"
        git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
        (
            cd "$TEMP_DIR/yay"
            makepkg -si --noconfirm
        )

        if ! have yay; then
            error "The yay build completed, but the yay command is still unavailable."
            exit 1
        fi
    fi

    info "Installing AUR packages with yay..."
    # Do not pass --noconfirm for AUR builds: PKGBUILDs should be reviewed.
    yay -S --needed -- "${AUR_PACKAGES[@]}"
else
    info "No AUR packages to install."
fi

info "Verifying which requested packages are installed..."
for package in "${PACMAN_PACKAGES[@]}" "${AUR_PACKAGES[@]}"; do
    [[ -n "$package" ]] || continue
    if pacman -Q "$package" >/dev/null 2>&1; then
        printf '[OK]      %s\\n' "$package"
    else
        printf '[MISSING] %s\\n' "$package"
        FAILED_PACKAGES+=("$package")
    fi
done

if ((${#FAILED_PACKAGES[@]} > 0)); then
    warn "Installation finished, but some requested packages are not installed:"
    printf '  %s\\n' "${FAILED_PACKAGES[@]}"
    warn "Check the log for details: $LOG_FILE"
    exit 2
fi

info "All requested packages are installed."
printf 'Log saved to: %s\\n' "$LOG_FILE"
