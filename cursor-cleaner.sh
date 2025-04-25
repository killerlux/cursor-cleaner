#!/bin/bash

# ==============================================================================
# == Cursor Cleaner & Machine ID Reset Script (Debian/Ubuntu) ==
# ==============================================================================
#
# DESCRIPTION:
# This script attempts to completely remove the Cursor application (installed
# via AppImage or extraction) and its associated user configuration data.
# It also resets the system's machine-id, which *may* help bypass trial
# limitations based on this identifier.
#
# TARGET AUDIENCE: Users who need to perform a clean reinstall of Cursor.
#
# SYSTEM REQUIREMENTS: Debian/Ubuntu or derivative using systemd.
# Requires bash, coreutils (rm, cat), systemd, sudo, apt.
#
# ==============================================================================
# == WARNINGS & DISCLAIMER ==
# ==============================================================================
#
# 1. HIGHLY DESTRUCTIVE: This script uses 'rm -rf' which forcefully deletes
#    files and directories WITHOUT confirmation (beyond the initial script
#    confirmation). MISTAKES CAN LEAD TO DATA LOSS OR SYSTEM DAMAGE.
# 2. DATA LOSS: All Cursor settings, cache, local history (if any not synced),
#    and related configuration WILL BE PERMANENTLY DELETED. Back up anything
#    important beforehand if needed.
# 3. MACHINE ID RESET: Changing the machine ID is generally safe but *might*
#    affect other software relying on it (rare). A REBOOT IS REQUIRED.
# 4. NO GUARANTEES: This script might not be sufficient to bypass all trial
#    mechanisms. Cursor could use other identifiers (MAC address, online
#    account, etc.).
# 5. USE AT YOUR OWN RISK: The author(s) are NOT responsible for any damage
#    or data loss caused by using this script. REVIEW THE CODE CAREFULLY.
# 6. ETHICAL USE: This script is provided for educational and testing purposes.
#    Please respect software licenses and terms of service. Consider
#    supporting developers by purchasing software you find valuable.
#
# ==============================================================================

# --- Configuration (Users might need to adjust these) ---
# Default Downloads directory (Common on English systems, change if different)
DOWNLOADS_DIR="$HOME/Downloads"
# French Downloads directory (Uncomment below and comment above if needed)
# DOWNLOADS_DIR="$HOME/Téléchargements"

APPIMAGE_PATTERN="Cursor-*.AppImage"  # Wildcard pattern for the AppImage file
EXTRACTED_DIR="$HOME/squashfs-root"   # Default extraction dir for AppImages mounted by the system

# --- Function for running commands with sudo ---
run_sudo() {
    echo "[sudo] Running: $@"
    if ! sudo "$@"; then
        echo "[ERROR] Failed to execute sudo command: '$@'. Please check permissions/output." >&2
        # Optionally exit here: exit 1
    fi
}

# --- Initial Checks and Confirmation ---
clear
echo "======================================================================"
echo " Cursor Cleaner & Machine ID Reset Script"
echo "======================================================================"
echo -e "\n\033[1;31mREAD THE WARNINGS IN THE SCRIPT SOURCE CODE BEFORE PROCEEDING.\033[0m"
echo "This script will:"
echo "  - Attempt to stop running Cursor processes."
echo "  - Delete Cursor AppImage file(s) matching '$APPIMAGE_PATTERN' in '$DOWNLOADS_DIR'."
echo "  - Delete the extracted AppImage directory '$EXTRACTED_DIR'."
echo "  - Delete Cursor user data from ~/.config, ~/.cache, ~/.local/share, ~/.cursor*, ~/.local/state."
echo "  - Delete associated desktop and icon files (system-wide and user-specific)."
echo "  - Reset the system's /etc/machine-id."
echo "  - Clean apt cache and update locate database."
echo -e "\n\033[1;33mTHIS ACTION IS IRREVERSIBLE AND DELETES DATA.\033[0m"

read -p "Type 'YES' in uppercase to confirm you understand and accept the risks: " CONFIRMATION
if [[ "$CONFIRMATION" != "YES" ]]; then
    echo "[ABORTED] User did not confirm."
    exit 1
fi

echo "--- Starting Cleanup Process ---"

# --- Stop Cursor Process ---
echo "[TASK] Attempting to stop running Cursor processes..."
killall cursor 2>/dev/null || echo "[INFO] No running 'cursor' process found or killall failed (this is often ok)."

# --- Remove Application Files ---
echo "[TASK] Removing Cursor application files..."
echo "  - Searching for '$APPIMAGE_PATTERN' in '$DOWNLOADS_DIR'..."
# Using find to handle multiple potential matches and deletion safely
find "$DOWNLOADS_DIR" -maxdepth 1 -name "$APPIMAGE_PATTERN" -print -delete || echo "[WARN] Could not find or delete AppImage files (maybe already deleted or path is wrong)."

echo "  - Removing extracted directory ($EXTRACTED_DIR)..."
if [ -d "$EXTRACTED_DIR" ]; then
  rm -rfv "$EXTRACTED_DIR"
  echo "    [OK] Removed $EXTRACTED_DIR"
else
  echo "    [INFO] Directory $EXTRACTED_DIR not found, skipping."
fi

# --- Remove User Config/Data ---
echo "[TASK] Removing user configuration, cache, and data..."
CONFIG_DIRS=(
    "$HOME/.config/Cursor"
    "$HOME/.cache/Cursor"
    "$HOME/.local/share/Cursor"
    "$HOME/.cursor"
    "$HOME/.cursor-server"
)
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -e "$dir" ]; then # Check if file or directory exists
        rm -rfv "$dir"
        echo "    [OK] Removed $dir"
    else
        echo "    [INFO] Path $dir not found, skipping."
    fi
done
# Handle potential state/log files with wildcard
STATE_PATTERN="$HOME/.local/state/cursor*"
if compgen -G "$STATE_PATTERN" > /dev/null; then
    echo "  - Removing state/log files matching $STATE_PATTERN..."
    rm -rfv $STATE_PATTERN
    echo "    [OK] Removed matching state/log files."
else
    echo "    [INFO] No state/log files found matching $STATE_PATTERN, skipping."
fi


# --- Remove Desktop/Icon Files ---
echo "[TASK] Removing desktop entries and icons..."
# User files
rm -fv ~/.local/share/applications/cursor*.desktop
rm -fv ~/.local/share/applications/co.anysphere.cursor*.desktop
rm -fv ~/.local/share/icons/cursor*.*
rm -fv ~/.local/share/icons/co.anysphere.cursor*.*

# System files (require sudo)
run_sudo rm -f /usr/share/applications/cursor*.desktop
run_sudo rm -f /usr/share/applications/co.anysphere.cursor*.desktop
run_sudo rm -f /usr/share/icons/hicolor/*/apps/cursor.png
run_sudo rm -f /usr/share/icons/hicolor/*/apps/co.anysphere.cursor.*
run_sudo rm -f /usr/share/pixmaps/cursor*.*
run_sudo rm -f /usr/share/pixmaps/co.anysphere.cursor.*

echo "[TASK] Updating desktop database..."
run_sudo update-desktop-database ~/.local/share/applications
run_sudo update-desktop-database /usr/share/applications

# --- Reset Machine ID ---
echo "[TASK] Resetting system machine ID..."
run_sudo rm -f /etc/machine-id
run_sudo rm -f /var/lib/dbus/machine-id # Often a symlink, remove just in case
run_sudo systemd-machine-id-setup
echo "[INFO] Machine ID regeneration requested. New ID:"
sudo cat /etc/machine-id || echo "[ERROR] Could not read new machine ID from /etc/machine-id."

# --- Final System Cleanup ---
echo "[TASK] Cleaning apt cache and updating locate database..."
run_sudo apt clean
run_sudo updatedb

# --- Final Instructions ---
echo "============================================================"
echo -e "\033[1;32m[SCRIPT COMPLETE]\033[0m Cursor removal and Machine ID reset finished."
echo -e "\033[1;31m[CRITICAL] A system REBOOT IS REQUIRED NOW!\033[0m"
echo "This ensures all services recognize the new machine ID and"
echo "all traces of the old session are cleared."
echo ""
echo -e "Please reboot your system manually using: \033[1;34msudo reboot\033[0m"
echo "============================================================"

exit 0 