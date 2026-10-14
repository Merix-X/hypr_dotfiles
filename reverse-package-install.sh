#!/usr/bin/env bash
#
# reverse-package-install.sh
#
# Safely reverse package installations performed from pkglist.txt and
# aur-pkglist.txt using pacman/yay.
#
# Run from the repository directory containing both package-list files.
# The script is intentionally conservative: it only proposes packages that
# are currently installed and have an "[ALPM] installed" log entry at or after
# the timestamp supplied by the user. It never automatically removes anything.
#
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

SCRIPT_NAME="${0##*/}"
BACKUP_DIR="${HOME}/.local/state/package-reversal"
LOG_FILE=""
WORK_DIR=""
CANDIDATE_FILE=""
SELECTED_FILE=""

cleanup() {
    [[ -n "${WORK_DIR:-}" && -d "$WORK_DIR" ]] && rm -rf -- "$WORK_DIR"
}
trap cleanup EXIT

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

warn() {
    printf 'WARNING: %s\n' "$*" >&2
}

info() {
    printf '\n==> %s\n' "$*"
}

command -v pacman >/dev/null 2>&1 || die "pacman was not found. This script is intended for Arch Linux."
command -v awk >/dev/null 2>&1 || die "Required command 'awk' was not found."
command -v date >/dev/null 2>&1 || die "Required command 'date' was not found."
command -v sudo >/dev/null 2>&1 || die "Required command 'sudo' was not found."

[[ $EUID -ne 0 ]] || die "Do not run this script as root. Run it as your normal user."

REPO_DIR="$(pwd -P)"
PKG_LIST="${REPO_DIR}/pkglist.txt"
AUR_LIST="${REPO_DIR}/aur-pkglist.txt"

[[ -f "$PKG_LIST" ]] || die "Missing ${PKG_LIST}. Run this script from the repository directory."
[[ -f "$AUR_LIST" ]] || die "Missing ${AUR_LIST}. Run this script from the repository directory."
[[ -r "$PKG_LIST" && -r "$AUR_LIST" ]] || die "Cannot read one or both package list files."

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/package-reversal.XXXXXXXX")"
ALL_LIST="${WORK_DIR}/all-packages.txt"
INSTALLED_LIST="${WORK_DIR}/installed-packages.txt"
LOG_EVENTS="${WORK_DIR}/log-events.tsv"
CANDIDATE_FILE="${WORK_DIR}/candidates.txt"
SELECTED_FILE="${WORK_DIR}/selected.txt"

# Parse package names from plain package-list files. Blank lines and comments
# are ignored. Repository prefixes (for example, extra/foo) are stripped.
awk '
    {
        sub(/[[:space:]]*#.*/, "")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "")
        if ($0 == "") next
        split($0, fields, /[[:space:]]+/)
        name = fields[1]
        sub(/^.*\//, "", name)
        if (name ~ /^[[:alnum:]@._+-]+$/ && !seen[name]++) print name
    }
' "$PKG_LIST" "$AUR_LIST" | sort -u > "$ALL_LIST"

[[ -s "$ALL_LIST" ]] || die "No valid package names were found in the two package lists."

info "Reading the current package database"
pacman -Qq 2>/dev/null | sort -u > "$INSTALLED_LIST" ||
    die "Could not query installed packages with pacman -Qq."

# Ask for the approximate local date/time when the two install commands were
# run. This avoids mistaking packages installed long before the experiment
# for packages added by it.
printf '\nWhen did you run the original yay/pacman installation commands?\n'
printf 'Enter local time as YYYY-MM-DD HH:MM (example: 2026-10-14 18:30).\n'
printf 'The timestamp is used to filter the pacman log; it is not sent anywhere.\n'
read -r -p "Installation start time: " START_INPUT

[[ -n "$START_INPUT" ]] || die "A start time is required; refusing to guess."

START_EPOCH="$(date -d "$START_INPUT" +%s 2>/dev/null)" ||
    die "Could not parse the date/time. Use YYYY-MM-DD HH:MM."
START_CANON="$(date -d "@${START_EPOCH}" '+%Y-%m-%d %H:%M:%S')"

# Read pacman.log and rotated compressed logs if present. Only successful
# install events count. Upgrades/reinstalls are deliberately excluded because
# an upgrade does not mean the package was newly introduced to the system.
LOG_SOURCES=()
[[ -r /var/log/pacman.log ]] && LOG_SOURCES+=(/var/log/pacman.log)
while IFS= read -r -d '' f; do LOG_SOURCES+=("$f"); done < <(
    find /var/log -maxdepth 1 -type f -name 'pacman.log.*.gz' -print0 2>/dev/null
)

((${#LOG_SOURCES[@]} > 0)) ||
    die "No readable pacman log was found under /var/log. Cannot safely identify newly installed packages."

: > "$LOG_EVENTS"
for log in "${LOG_SOURCES[@]}"; do
    if [[ "$log" == *.gz ]]; then
        command -v gzip >/dev/null 2>&1 || die "gzip is needed to read ${log}."
        gzip -cd -- "$log" 2>/dev/null || warn "Could not read rotated log ${log}"
    else
        cat -- "$log"
    fi
done | awk -v start="$START_CANON" '
    match($0, /^\[([^]]+)\] \[ALPM\] installed ([^ ]+) \(([^)]*)\)/, m) {
        if (m[1] >= start) {
            pkg = m[2]
            # Log lines include package version in parentheses; only emit the
            # package name and timestamp for matching against package lists.
            print pkg "\t" m[1]
        }
    }
' > "$LOG_EVENTS" || die "Failed while processing pacman logs."

# For each listed package, require all of:
#   - it is currently installed;
#   - the pacman log records a new installation at/after the chosen time.
# Existing packages, upgrades, and packages absent from the log are excluded.
comm -12 "$ALL_LIST" "$INSTALLED_LIST" > "${WORK_DIR}/listed-installed.txt"
awk -F '\t' '{print $1}' "$LOG_EVENTS" | sort -u > "${WORK_DIR}/logged-installed.txt"
comm -12 "${WORK_DIR}/listed-installed.txt" "${WORK_DIR}/logged-installed.txt" > "$CANDIDATE_FILE"

info "Installation-log review"
printf 'Repository directory: %s\n' "$REPO_DIR"
printf 'Package names in lists: %s\n' "$(wc -l < "$ALL_LIST" | tr -d ' ')"
printf 'Currently installed names from lists: %s\n' "$(wc -l < "${WORK_DIR}/listed-installed.txt" | tr -d ' ')"
printf 'Log window starts at: %s\n' "$START_CANON"
printf 'Packages matching a new-install log entry: %s\n' "$(wc -l < "$CANDIDATE_FILE" | tr -d ' ')"

if [[ ! -s "$CANDIDATE_FILE" ]]; then
    cat <<'EOF'

No packages could be safely identified from the available log entries.

Nothing has been removed. Possible reasons:
- The timestamp is later than the installation.
- The pacman log has been rotated or deleted.
- The packages were already installed, upgraded, or installed before the chosen time.
- The package lists do not match the names recorded in the logs.

Re-run with an earlier, accurate start time if appropriate. Do not broaden the
timestamp blindly: that can include unrelated installations.
EOF
    exit 0
fi

printf '\nCandidate packages (new-install log entry + present in package lists):\n'
while IFS= read -r pkg; do
    event_time="$(awk -F '\t' -v p="$pkg" '$1 == p {t=$2} END {print t}' "$LOG_EVENTS")"
    printf '  %-36s %s\n' "$pkg" "${event_time:-timestamp unavailable}"
done < "$CANDIDATE_FILE"

cat <<'EOF'

Important limitations:
- pacman logs record package operations, not which command initiated them.
- If unrelated packages were installed after the supplied timestamp and are
  also present in these lists, they may appear as candidates.
- A package that was installed before the timestamp and then upgraded is not
  considered newly installed by this script.
- Packages installed by an AUR helper are managed by pacman once installed.
EOF

printf '\nReview the candidates above before continuing.\n'
read -r -p "Do you want to choose packages to remove? Type REVIEW to continue: " REVIEW
[[ "$REVIEW" == "REVIEW" ]] || { info "Cancelled. Nothing was removed."; exit 0; }

cp -- "$CANDIDATE_FILE" "$SELECTED_FILE"
printf '\nYou may edit the removal list before proceeding.\n'
printf 'A temporary list is at: %s\n' "$SELECTED_FILE"
printf 'Enter package names to KEEP, separated by spaces, or press Enter to keep none.\n'
read -r -p "Packages to keep: " KEEP_INPUT

if [[ -n "$KEEP_INPUT" ]]; then
    KEEP_FILE="${WORK_DIR}/keep.txt"
    printf '%s\n' $KEEP_INPUT | sort -u > "$KEEP_FILE"
    while IFS= read -r pkg; do
        if ! grep -Fxq -- "$pkg" "$CANDIDATE_FILE"; then
            warn "Ignoring '$pkg': it is not in the candidate list."
        fi
    done < "$KEEP_FILE"
    grep -Fvx -f "$KEEP_FILE" "$CANDIDATE_FILE" > "${WORK_DIR}/remaining.txt" || true
    mv -- "${WORK_DIR}/remaining.txt" "$SELECTED_FILE"
fi

if [[ ! -s "$SELECTED_FILE" ]]; then
    info "No packages selected for removal. Nothing was changed."
    exit 0
fi

# Save the exact proposed list and relevant log entries for an audit trail.
mkdir -p -- "$BACKUP_DIR"
RUN_ID="$(date '+%Y%m%d-%H%M%S')"
AUDIT_DIR="${BACKUP_DIR}/${RUN_ID}"
mkdir -m 700 -- "$AUDIT_DIR"
cp -- "$ALL_LIST" "$AUDIT_DIR/package-lists-combined.txt"
cp -- "$CANDIDATE_FILE" "$AUDIT_DIR/log-matched-candidates.txt"
cp -- "$SELECTED_FILE" "$AUDIT_DIR/selected-for-removal.txt"
cp -- "$LOG_EVENTS" "$AUDIT_DIR/matching-install-log-events.tsv"
printf '%s\n' "$START_CANON" > "$AUDIT_DIR/installation-start-time.txt"

info "Final removal plan"
cat "$SELECTED_FILE"
printf '\nThe next operation is equivalent to: sudo pacman -Rns -- <selected packages>\n'
printf 'pacman will show its transaction and dependency-removal plan before changing anything.\n'
read -r -p "Type REMOVE to run the pacman transaction, or anything else to cancel: " CONFIRM
[[ "$CONFIRM" == "REMOVE" ]] || {
    info "Cancelled. Nothing was removed."
    printf 'Audit files were saved in: %s\n' "$AUDIT_DIR"
    exit 0
}

mapfile -t REMOVE_PKGS < "$SELECTED_FILE"
((${#REMOVE_PKGS[@]} > 0)) || die "Internal error: empty removal list."

info "Starting removal"
set +e
sudo pacman -Rns -- "${REMOVE_PKGS[@]}"
STATUS=$?
set -e

if (( STATUS != 0 )); then
    warn "pacman did not complete successfully (exit code ${STATUS}). Review its output."
    warn "Some or all packages may remain installed; check with pacman -Q."
    printf 'Audit files: %s\n' "$AUDIT_DIR"
    exit "$STATUS"
fi

info "Removal transaction completed"
printf 'Audit files: %s\n' "$AUDIT_DIR"
printf '\nVerify your desktop, shell, audio, network, and login manager before rebooting.\n'
printf 'This script does not reverse configuration-file changes or package data outside pacman.\n'
