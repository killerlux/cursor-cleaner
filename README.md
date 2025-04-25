# Cursor Cleaner & Machine ID Reset Script

A robust script for completely removing the Cursor application and its associated configuration data from Debian/Ubuntu systems. This script also resets the system's machine ID, which may help bypass trial limitations based on this identifier.

## ⚠️ IMPORTANT WARNINGS

1. **HIGHLY DESTRUCTIVE**: This script uses `rm -rf` which forcefully deletes files and directories without confirmation (beyond the initial script confirmation). Mistakes can lead to data loss or system damage.
2. **DATA LOSS**: All Cursor settings, cache, local history (if any not synced), and related configuration will be permanently deleted. Back up anything important beforehand.
3. **MACHINE ID RESET**: Changing the machine ID is generally safe but might affect other software relying on it (rare). A reboot is required.
4. **NO GUARANTEES**: This script might not be sufficient to bypass all trial mechanisms. Cursor could use other identifiers (MAC address, online account, etc.).
5. **USE AT YOUR OWN RISK**: The author(s) are not responsible for any damage or data loss caused by using this script. Review the code carefully.
6. **ETHICAL USE**: This script is provided for educational and testing purposes. Please respect software licenses and terms of service. Consider supporting developers by purchasing software you find valuable.

## 🛠️ System Requirements

- Debian/Ubuntu or derivative using systemd
- Bash shell
- Coreutils (rm, cat)
- Systemd
- Sudo access
- Apt package manager

## 📋 Features

- Stops running Cursor processes
- Removes Cursor AppImage files
- Deletes extracted AppImage directories
- Removes all Cursor configuration and cache data
- Cleans up desktop entries and icons
- Resets system machine ID
- Updates system databases

## 🚀 Installation & Usage

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/yourusername/cursor-cleaner/main/cursor-cleaner.sh
   ```

2. Make it executable:
   ```bash
   chmod +x cursor-cleaner.sh
   ```

3. Run the script:
   ```bash
   ./cursor-cleaner.sh
   ```

4. Read the warnings carefully and type `YES` when prompted to confirm.

5. Enter your password when prompted by sudo.

6. **IMPORTANT**: Reboot your system after the script completes:
   ```bash
   sudo reboot
   ```

## 🔧 Configuration

The script includes some configurable variables at the top:

```bash
# Default Downloads directory (Common on English systems)
DOWNLOADS_DIR="$HOME/Downloads"

# French Downloads directory (Uncomment if needed)
# DOWNLOADS_DIR="$HOME/Téléchargements"

APPIMAGE_PATTERN="Cursor-*.AppImage"
EXTRACTED_DIR="$HOME/squashfs-root"
```

Adjust these variables if needed for your system configuration.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Disclaimer

This script is provided "as is" without warranty of any kind. Use at your own risk. The author(s) are not responsible for any damage or data loss caused by using this script. 