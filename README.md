# MTK Driver Loader v2.0 OLD PROJECT REVIVED

[![GitHub](https://img.shields.io/badge/GitHub-0xb0rn3-blue?logo=github)](https://github.com/0xb0rn3/mtkdrvlder)
[![Version](https://img.shields.io/badge/Version-2.0-green)](https://github.com/0xb0rn3/mtkdrvlder)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

An enhanced, user-friendly script for managing MTK wireless adapters on Linux systems. This tool provides comprehensive driver installation, adapter management, and LED control with improved error handling and logging.

## 🚀 Features

### Core Functionality
- **Driver Installation**: Automated installation of MTK 7612U drivers with dependency management
- **Adapter Management**: Enable/disable wireless adapters with intelligent status checking
- **LED Control**: Full control over adapter LED indicators (on/off/blink)
- **RF-Kill Management**: Automatic detection and handling of RF-kill blocks

### Enhanced Features
- **Colorized Output**: Easy-to-read colored terminal output
- **Comprehensive Logging**: Detailed logging with timestamps
- **Configuration Management**: Persistent settings storage
- **System Information**: Detailed system and driver status reporting
- **Error Handling**: Robust error detection and recovery
- **Interactive Menu**: User-friendly menu-driven interface
- **Command Line Interface**: Full CLI support for automation

## 📋 Requirements

- **Operating System**: Linux (Ubuntu/Debian recommended)
- **Architecture**: x86_64, ARM64
- **Permissions**: sudo access required
- **Dependencies**: Automatically installed by the script
  - `git`
  - `dkms`
  - `build-essential`
  - `linux-headers`

## 🔧 Installation

### Quick Install
```bash
# Clone the repository
git clone https://github.com/0xb0rn3/mtkdrvlder.git
cd mtkdrvlder

# Make the script executable
chmod +x mtkloader.sh

# Run the interactive menu
./mtkloader.sh
```

### Direct Download
```bash
wget https://raw.githubusercontent.com/0xb0rn3/mtkdrvlder/main/mtkloader.sh
chmod +x mtkloader.sh
./mtkloader.sh
```

## 🖥️ Usage

### Interactive Menu
Launch the script without arguments to access the interactive menu:
```bash
./mtkloader.sh
```

The menu provides the following options:
1. Install driver
2. Enable adapter
3. Disable adapter
4. Turn on LED
5. Turn off LED
6. Blink LED
7. Configure settings
8. Check driver status
9. Show interface status
10. Check system info
11. View logs
12. Exit

### Command Line Interface
For automation and scripting, use direct commands:

```bash
# Install the MTK driver
./mtkloader.sh install

# Enable the wireless adapter
./mtkloader.sh enable

# Disable the wireless adapter
./mtkloader.sh disable

# LED control
./mtkloader.sh led-on
./mtkloader.sh led-off
./mtkloader.sh led-blink

# System information
./mtkloader.sh status
./mtkloader.sh info

# Configuration
./mtkloader.sh configure

# Help
./mtkloader.sh --help
```

## ⚙️ Configuration

The script creates a configuration file at `~/.mtkloader_config` to store your preferences:

- **Interface Name**: Default wireless interface (e.g., wlan0)
- **Permanent Power**: Keep adapter always powered
- **Repository URL**: Source repository for drivers

### Environment Variables
You can override settings using environment variables:
```bash
INTERFACE=wlan1 ./mtkloader.sh
```

## 📊 System Information

The enhanced version provides detailed system information including:
- Operating system and kernel version
- System architecture
- Current user and permissions
- Network interface status
- Driver loading status
- USB device information

## 🔍 Troubleshooting

### Common Issues

**Driver Installation Fails**
```bash
# Check system compatibility
./mtkloader.sh info

# Verify dependencies
sudo apt update
sudo apt install dkms build-essential linux-headers-$(uname -r)
```

**Interface Not Found**
```bash
# List available interfaces
ip link show

# Configure correct interface
./mtkloader.sh configure
```

**LED Control Not Working**
```bash
# Check if driver is loaded
./mtkloader.sh status

# Verify PHY path exists
ls /sys/kernel/debug/ieee80211/*/mt76
```

**RF-Kill Issues**
```bash
# Check RF-kill status
rfkill list

# Unblock all RF devices
sudo rfkill unblock all
```

### Logs and Debugging

View detailed logs:
```bash
# From the menu (option 11)
./mtkloader.sh

# Or directly
cat /tmp/mtkloader.log
```

## 🛡️ Security Considerations

- The script requires sudo privileges for system-level operations
- Running as root is discouraged and will trigger warnings
- All operations are logged for audit purposes
- Configuration files are stored in user home directory

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

### Development Setup
```bash
git clone https://github.com/0xb0rn3/mtkdrvlder.git
cd mtkdrvlder
# Make your changes
# Test thoroughly
# Submit PR
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original driver repository: [morrownr/7612u](https://github.com/morrownr/7612u)
- Linux wireless community
- Contributors and testers

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/0xb0rn3/mtkdrvlder/issues)
- **Discussions**: [Community discussions](https://github.com/0xb0rn3/mtkdrvlder/discussions)

## 🔄 Changelog

### v2.0
- Added colorized output
- Comprehensive error handling
- Configuration management
- Enhanced logging
- System information display
- Improved menu interface
- Command-line argument support
- Better dependency checking

### v1.0
- Basic driver installation
- Simple LED control
- RF-kill management

---

**Developer**: 0xb0rn3  
**GitHub**: [github.com/0xb0rn3/mtkdrvlder](https://github.com/0xb0rn3/mtkdrvlder)
