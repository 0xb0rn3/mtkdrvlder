# MTK Driver Loader v0.1.2 OLD PROJECT REVIVED
## 🔍 Troubleshooting

### Quick Fixes

**Installation Issues**
```bash
# Try different installation method
./mtkloader.sh detect  # Check what's detected
./mtkloader.sh install # Manual installation
```

**No Interface Detected**
```bash
# Check available interfaces
ip link show
iwconfig

# Manual interface specification
INTERFACE=wlan1 ./mtkloader.sh enable
```

**Driver Not Loading**
```bash
# Check driver status
./mtkloader.sh status
lsmod | grep mt76# MTK Universal Driver Loader v2.1

[![GitHub](https://img.shields.io/badge/GitHub-0xb0rn3-blue?logo=github)](https://github.com/0xb0rn3/mtkdrvlder)
[![Version](https://img.shields.io/badge/Version-2.1-green)](https://github.com/0xb0rn3/mtkdrvlder)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Compatibility](https://img.shields.io/badge/Linux-Universal-orange)](https://github.com/0xb0rn3/mtkdrvlder)

Universal Linux script for MTK wireless adapters with automatic hardware detection, minimal installation visuals, and support for ALL major Linux distributions. One-command setup with intelligent auto-detection.

## 🚀 Features

### Universal Compatibility
- **ALL Linux Distributions**: Ubuntu, Debian, Fedora, CentOS, Arch, Manjaro, openSUSE, Alpine, Void, Gentoo
- **Automatic Package Manager Detection**: apt, dnf, pacman, zypper, apk, emerge, xbps
- **Smart Dependency Installation**: Installs correct packages for each distribution
- **Hardware Auto-Detection**: Automatically finds wireless interfaces and devices

### Minimal Installation Experience  
- **One-Command Setup**: `./mtkloader.sh quick` - everything automated
- **Minimal Visuals**: Clean, simple output with essential information only
- **Silent Mode**: `./mtkloader.sh -q` for completely quiet operation
- **Progress Indicators**: Simple checkmarks and minimal status updates

### Core Functionality
- **MTK Driver Installation**: Automated 7612U/7610U driver installation
- **Interface Management**: Auto-detect and manage wireless interfaces
- **LED Control**: Full LED control (on/off/blink) with hardware detection
- **RF-Kill Management**: Automatic RF-kill detection and unblocking

## 📋 Supported Systems

### Linux Distributions
- **Debian Family**: Ubuntu, Debian, Linux Mint, Elementary OS, Zorin OS
- **Red Hat Family**: Fedora, RHEL, CentOS, Rocky Linux, AlmaLinux  
- **Arch Family**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux
- **SUSE Family**: openSUSE Leap, openSUSE Tumbleweed
- **Others**: Alpine Linux, Void Linux, Gentoo Linux

### Package Managers
- **apt** (Debian/Ubuntu)
- **dnf/yum** (Fedora/RHEL)
- **pacman** (Arch Linux)
- **zypper** (openSUSE)
- **apk** (Alpine)
- **emerge** (Gentoo)
- **xbps** (Void Linux)

### Hardware Support
- **MTK 7612U** USB adapters
- **MTK 7610U** USB adapters  
- **Auto-detection** of compatible devices
- **Universal interface** support (wlan0, wlp*, wlx*)

## ⚡ Quick Start (Recommended)

### One-Command Installation
```bash
# Download and run automatic setup
curl -s https://raw.githubusercontent.com/0xb0rn3/mtkdrvlder/main/mtkloader.sh | bash -s quick
```

### Manual Download + Quick Setup
```bash
# Download the script
wget https://raw.githubusercontent.com/0xb0rn3/mtkdrvlder/main/mtkloader.sh
chmod +x mtkloader.sh

# Run automatic setup (detects everything)
./mtkloader.sh quick
```

### Silent Installation
```bash
# Completely quiet installation
./mtkloader.sh -q
```

## 🔧 Installation Options

### Git Clone Method
```bash
git clone https://github.com/0xb0rn3/mtkdrvlder.git
cd mtkdrvlder
chmod +x mtkloader.sh
./mtkloader.sh quick
```

### Direct Download Method
```bash
wget https://raw.githubusercontent.com/0xb0rn3/mtkdrvlder/main/mtkloader.sh
chmod +x mtkloader.sh
./mtkloader.sh auto
```

## 🖥️ Usage

### Automatic Mode (Recommended)
The script automatically detects your Linux distribution, hardware, and installs everything needed:

```bash
# Automatic setup with detection
./mtkloader.sh quick
./mtkloader.sh auto  
./mtkloader.sh setup

# Silent automatic setup
./mtkloader.sh -q
```

### Interactive Menu
Simple 8-option menu for manual control:
```bash
./mtkloader.sh
```

### Command Line Interface
Direct commands for automation:

```bash
# Hardware detection
./mtkloader.sh detect

# Driver installation  
./mtkloader.sh install

# Interface control
./mtkloader.sh enable
./mtkloader.sh disable

# LED control
./mtkloader.sh led-on
./mtkloader.sh led-off  
./mtkloader.sh led-blink

# System status
./mtkloader.sh status

# Help
./mtkloader.sh --help
```

## 🔧 Auto-Detection Features

### Hardware Detection
- **USB Wireless Devices**: Automatically scans and identifies MTK devices
- **Network Interfaces**: Detects wlan0, wlp*, wlx* interfaces automatically  
- **MTK Device Recognition**: Specifically identifies MediaTek USB adapters
- **Driver Status**: Checks if MTK drivers are already loaded

### Distribution Detection  
- **Package Manager**: Automatically detects apt/dnf/pacman/zypper/etc
- **Dependency Mapping**: Installs correct packages per distribution
- **Kernel Headers**: Finds and installs matching kernel headers
- **Build Tools**: Installs appropriate build tools for each system

### Smart Installation
- **Minimal Dependencies**: Only installs what's actually needed
- **Version Detection**: Handles different package names across distributions  
- **Fallback Options**: Uses alternative methods if primary tools unavailable
- **Clean Installation**: Removes temporary files automatically

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

### v0.1.2
- Added colorized output
- Comprehensive error handling
- Configuration management
- Enhanced logging
- System information display
- Improved menu interface
- Command-line argument support
- Better dependency checking

### v0.1.1
- Basic driver installation
- Simple LED control
- RF-kill management

---

**Developer**: 0xb0rn3  
**GitHub**: [github.com/0xb0rn3/mtkdrvlder](https://github.com/0xb0rn3/mtkdrvlder)
