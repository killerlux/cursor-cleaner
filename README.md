# 🧹 Cursor Cleaner & Machine ID Reset Script

A powerful, interactive script for completely removing the Cursor application and its associated configuration data from Debian/Ubuntu systems. This script features a beautiful terminal UI with animations, progress bars, and color-coded output.

![Terminal Preview](https://raw.githubusercontent.com/killerlux/cursor-cleaner/main/.github/images/preview.gif)

## ✨ Features

### Core Functionality
- 🔄 Complete Cursor application removal
- 🗑️ Thorough cleanup of all associated files
- 🆔 System machine ID reset capability
- 🧹 Comprehensive system cleanup

### UI/UX Enhancements
- 🎨 Rich color-coded output for better readability
- 🔄 Loading spinners for background tasks
- 📊 Progress bars for long operations
- ✨ Interactive confirmations
- 🎯 Clear section headers and visual organization
- 📝 Detailed operation feedback
- 🚦 Status indicators and symbols

## ⚠️ Important Warnings

1. **HIGHLY DESTRUCTIVE**: Uses `rm -rf` for forceful deletion
2. **DATA LOSS**: Permanently removes all Cursor settings and data
3. **MACHINE ID RESET**: Requires system reboot
4. **NO GUARANTEES**: May not bypass all trial mechanisms
5. **USE AT YOUR OWN RISK**: Review code before running
6. **ETHICAL USE**: Respect software licenses

## 🛠️ System Requirements

- **OS**: Debian/Ubuntu or derivative
- **Core**: systemd
- **Shell**: Bash
- **Utilities**:
  - coreutils (rm, cat)
  - systemd
  - sudo access
  - apt package manager
- **Terminal**: Supports ANSI color codes

## 📋 What It Removes

- ⚡ Running Cursor processes
- 📦 AppImage files
- 📁 Extracted AppImage directories
- ⚙️ Configuration data:
  - ~/.config/Cursor
  - ~/.cache/Cursor
  - ~/.local/share/Cursor
  - ~/.cursor*
- 🖥️ Desktop entries and icons
- 🆔 System machine ID (with reset)

## 🚀 Installation & Usage

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/killerlux/cursor-cleaner/main/cursor-cleaner.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x cursor-cleaner.sh
   ```

3. **Run the script**:
   ```bash
   ./cursor-cleaner.sh
   ```

4. **Follow the interactive prompts**:
   - Read and acknowledge warnings
   - Confirm execution
   - Enter sudo password when prompted
   - Choose whether to reboot immediately

## 🔧 Configuration

The script includes configurable variables at the top:

```bash
# Default Downloads directory (Common on English systems)
DOWNLOADS_DIR="$HOME/Downloads"

# French Downloads directory (Uncomment if needed)
# DOWNLOADS_DIR="$HOME/Téléchargements"

# AppImage pattern to match
APPIMAGE_PATTERN="Cursor-*.AppImage"

# Default extraction directory
EXTRACTED_DIR="$HOME/squashfs-root"
```

## 🎨 Color Scheme

The script uses a carefully chosen color scheme for different types of messages:
- 🟦 Blue: Information messages
- 🟨 Yellow: Warnings and cautions
- 🟩 Green: Success messages
- 🟥 Red: Error messages
- 🟪 Magenta: Section headers
- 🟦 Cyan: Progress indicators

## 🤝 Contributing

Contributions are welcome! Here's how you can help:
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This script is provided "as is" without warranty of any kind. Use at your own risk. The author(s) are not responsible for any damage or data loss caused by using this script.

## 🙏 Support

If you find this tool useful, consider:
- ⭐ Starring the repository
- 🐛 Reporting issues
- 🔀 Contributing improvements
- 📢 Sharing with others 