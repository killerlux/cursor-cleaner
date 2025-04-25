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

# --- Terminal Colors and Formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color
TICK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
INFO="${BLUE}ℹ${NC}"
WARN="${YELLOW}⚠${NC}"

# --- Spinner Animation ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local msg="$2"
    printf "${DIM}  %s" "$msg"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r  ${CYAN}[%c]${NC} %s" "$spinstr" "$msg"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r  ${TICK} %s\n" "$msg"
}

# --- Progress Bar ---
progress_bar() {
    local duration=$1
    local msg="$2"
    local width=40
    local progress=0
    local fill
    local remain
    
    echo -ne "\n  ${msg}\n  "
    while [ $progress -le 100 ]; do
        let fill=($width*$progress/100)
        let remain=$width-$fill
        printf "\r  ${CYAN}[${NC}"
        printf "%${fill}s" '' | tr ' ' '█'
        printf "%${remain}s" '' | tr ' ' '░'
        printf "${CYAN}]${NC} ${progress}%%"
        progress=$((progress + 2))
        sleep $(echo "scale=3; $duration/50" | bc)
    done
    echo -e "\n"
}

# --- Fancy Print Functions ---
print_header() {
    clear
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                Cursor Cleaner & Machine ID Reset Script${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${MAGENTA}▓▒░ ${BOLD}$1${NC} ${MAGENTA}░▒▓${NC}"
    echo -e "${DIM}${MAGENTA}──────────────────────────────────────────${NC}\n"
}

print_warning() {
    echo -e "  ${WARN} ${YELLOW}$1${NC}"
}

print_info() {
    echo -e "  ${INFO} ${BLUE}$1${NC}"
}

print_success() {
    echo -e "  ${TICK} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "  ${CROSS} ${RED}$1${NC}" >&2
}

# --- Configuration (Users might need to adjust these) ---
# Default Downloads directory (Common on English systems, change if different)
DOWNLOADS_DIR="$HOME/Downloads"
# French Downloads directory (Uncomment below and comment above if needed)
# DOWNLOADS_DIR="$HOME/Téléchargements"

APPIMAGE_PATTERN="Cursor-*.AppImage"  # Wildcard pattern for the AppImage file
EXTRACTED_DIR="$HOME/squashfs-root"   # Default extraction dir for AppImages mounted by the system

# --- Function for running commands with sudo ---
run_sudo() {
    echo -e "  ${INFO} Running: ${CYAN}$@${NC}"
    if ! sudo "$@"; then
        print_error "Failed to execute sudo command: '$@'"
    fi
}

# --- Initial Checks and Confirmation ---
print_header

# Display warnings
print_section "IMPORTANT WARNINGS"
print_warning "This script performs destructive operations that cannot be undone!"
print_warning "All Cursor settings and data will be permanently deleted."
print_warning "A system reboot will be required after completion."
echo

# Display actions
print_section "ACTIONS TO BE PERFORMED"
print_info "1. Stop running Cursor processes"
print_info "2. Remove Cursor AppImage files"
print_info "3. Delete configuration data"
print_info "4. Clean up system files"
print_info "5. Reset machine ID"
print_info "6. Update system databases"
echo

# Get confirmation
echo -e "${YELLOW}${BOLD}Do you understand and accept the risks?${NC}"
read -p "Type 'YES' in uppercase to confirm: " CONFIRMATION
if [[ "$CONFIRMATION" != "YES" ]]; then
    print_error "Operation cancelled by user"
    exit 1
fi

# --- Main Operations ---
print_section "STARTING CLEANUP PROCESS"

# Stop Cursor Process
print_info "Stopping Cursor processes..."
killall cursor 2>/dev/null &
spinner $! "Terminating running instances"

# Remove Application Files
print_info "Removing application files..."
(find "$DOWNLOADS_DIR" -maxdepth 1 -name "$APPIMAGE_PATTERN" -print -delete) &
spinner $! "Cleaning AppImage files"

if [ -d "$EXTRACTED_DIR" ]; then
    (rm -rf "$EXTRACTED_DIR") &
    spinner $! "Removing extracted directory"
fi

# Remove User Config/Data with progress simulation
print_section "CLEANING USER DATA"
CONFIG_DIRS=(
    "$HOME/.config/Cursor"
    "$HOME/.cache/Cursor"
    "$HOME/.local/share/Cursor"
    "$HOME/.cursor"
    "$HOME/.cursor-server"
)

progress_bar 3 "Removing configuration directories..."
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -e "$dir" ]; then
        rm -rf "$dir"
        print_success "Removed $dir"
    else
        print_info "Skipped $dir (not found)"
    fi
done

# Desktop/Icon Cleanup
print_section "CLEANING SYSTEM FILES"
progress_bar 2 "Removing desktop entries and icons..."

# User files
rm -f ~/.local/share/applications/cursor*.desktop
rm -f ~/.local/share/applications/co.anysphere.cursor*.desktop
rm -f ~/.local/share/icons/cursor*.*
rm -f ~/.local/share/icons/co.anysphere.cursor*.*

# System files
run_sudo rm -f /usr/share/applications/cursor*.desktop
run_sudo rm -f /usr/share/applications/co.anysphere.cursor*.desktop
run_sudo rm -f /usr/share/icons/hicolor/*/apps/cursor.png
run_sudo rm -f /usr/share/icons/hicolor/*/apps/co.anysphere.cursor.*
run_sudo rm -f /usr/share/pixmaps/cursor*.*
run_sudo rm -f /usr/share/pixmaps/co.anysphere.cursor.*

print_info "Updating desktop database..."
run_sudo update-desktop-database ~/.local/share/applications
run_sudo update-desktop-database /usr/share/applications

# Reset Machine ID
print_section "RESETTING SYSTEM IDENTITY"
progress_bar 2 "Resetting machine ID..."
run_sudo rm -f /etc/machine-id
run_sudo rm -f /var/lib/dbus/machine-id
run_sudo systemd-machine-id-setup

# Show new machine ID
echo -e "\n${CYAN}New Machine ID:${NC}"
sudo cat /etc/machine-id || print_error "Could not read new machine ID"

# Final Cleanup
print_section "FINAL CLEANUP"
progress_bar 2 "Cleaning system caches..."
run_sudo apt clean
run_sudo updatedb

# Final Instructions
echo -e "\n${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}               ✨ CLEANUP COMPLETE! ✨${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}\n"

print_warning "A SYSTEM REBOOT IS REQUIRED TO COMPLETE THE PROCESS"
echo -e "\n${BOLD}Would you like to reboot now? ${NC}(y/N): "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}System will reboot in 5 seconds...${NC}"
    sleep 5
    sudo reboot
else
    print_info "Please remember to reboot your system manually"
    print_info "You can reboot using: ${CYAN}sudo reboot${NC}"
fi

exit 0 