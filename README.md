# MTK Universal Driver Loader
A universal Linux driver loader for MediaTek USB wireless adapters with automatic distribution detection and minimal configuration.

## 🚀 Features
- **Universal Linux Support**: Automatic detection and support for major Linux distributions
- **Zero Configuration**: Auto-detects hardware and wireless interfaces  
- **Minimal Dependencies**: Installs only what's needed for your specific system
- **LED Control**: Hardware LED management for supported devices
- **Interactive & CLI Modes**: Both menu-driven and command-line interfaces
- **Comprehensive Logging**: Detailed operation logs for troubleshooting
- **In-Kernel Driver Support**: Utilizes modern kernel drivers when available (Linux 4.19+)
- **Fallback Source Installation**: Automatic fallback to source compilation when needed

## 📋 Supported Distributions
| Distribution Family | Package Manager | Distributions |
|-------------------|----------------|---------------|
| **Debian-based** | apt | Ubuntu, Debian, Linux Mint, elementary OS, Zorin, Raspbian |
| **Red Hat-based** | dnf | Fedora, RHEL, CentOS, Rocky Linux, AlmaLinux |
| **Arch-based** | pacman | Arch Linux, Manjaro, EndeavourOS, Garuda |
| **SUSE-based** | zypper | openSUSE, SUSE Linux Enterprise |
| **Alpine** | apk | Alpine Linux |
| **Void** | xbps | Void Linux |
| **Gentoo** | emerge | Gentoo Linux |

## 🔧 Installation
### Quick Install (Recommended)
```bash
# Download the script
wget https://raw.githubusercontent.com/0xb0rn3/mtkdrvlder/main/mtkloader.sh
# Make it executable
chmod +x mtkloader.sh
# Run automatic setup
./mtkloader.sh quick
```

### Manual Download
```bash
# Clone the repository
git clone https://github.com/0xb0rn3/mtkdrvlder.git
cd mtkdrvlder
# Make executable
chmod +x mtkloader.sh
# Run setup
./mtkloader.sh
```

## 🎯 Usage
### Interactive Mode
Simply run the script without arguments for a menu-driven interface:
```bash
./mtkloader.sh
```

**Menu Options:**
1. **Quick Setup (Auto)** - Automatic detection and installation
2. **Install Driver** - Driver installation only
3. **Enable Interface** - Activate wireless interface
4. **LED On** - Turn on hardware LED
5. **LED Off** - Turn off hardware LED
6. **LED Blink** - Enable LED blinking
7. **Status** - Show system and device status
8. **Configure Module Parameters** - Set module configuration
9. **Exit** - Exit the program

### Command Line Mode
| Command | Description | Example |
|---------|-------------|---------|
| `quick` / `auto` / `setup` | Automatic setup (recommended) | `./mtkloader.sh quick` |
| `install` | Install driver only | `./mtkloader.sh install` |
| `enable` | Enable wireless interface | `./mtkloader.sh enable` |
| `disable` | Disable wireless interface | `./mtkloader.sh disable` |
| `led-on` | Turn LED on | `./mtkloader.sh led-on` |
| `led-off` | Turn LED off | `./mtkloader.sh led-off` |
| `led-blink` | Enable LED blinking | `./mtkloader.sh led-blink` |
| `status` | Show device status | `./mtkloader.sh status` |
| `detect` | Detect hardware only | `./mtkloader.sh detect` |
| `config` | Configure module parameters | `./mtkloader.sh config` |
| `-q` / `--quiet` | Quiet mode setup | `./mtkloader.sh -q` |
| `-h` / `--help` | Show help information | `./mtkloader.sh -h` |

### Advanced Usage Examples
```bash
# Silent installation
./mtkloader.sh --quiet
# Check what hardware is detected
./mtkloader.sh detect
# Get detailed status information
./mtkloader.sh status
# Enable interface after driver installation
./mtkloader.sh enable
# Configure module parameters
./mtkloader.sh config
```

## 🔍 Hardware Detection
The tool automatically detects:
- **USB Wireless Devices**: Via `lsusb` command (including MediaTek vendor ID: 0e8d)
- **PCI Wireless Devices**: Via `lspci` command  
- **Network Interfaces**: Via `ip link` and `iwconfig`
- **MediaTek Devices**: Specific detection for MTK chipsets (MT7612U, MT76x2u)
- **Existing Drivers**: Checks for already loaded kernel modules

### Supported Chipsets
- **MT7612U** - Primary target chipset
- **MT76x2u** - Via in-kernel mt76x2u driver
- **MT76 family** - General MT76 framework support

### Supported Interface Names
- `wlan*` (e.g., wlan0, wlan1)
- `wlp*` (e.g., wlp2s0)
- `wlx*` (e.g., wlx00c0ca123456)

## 🛠️ Dependencies
The tool automatically installs required dependencies based on your distribution:

### Core Dependencies
- **Build Tools**: GCC, Make, and build essentials
- **Kernel Headers**: Matching your current kernel version
- **DKMS**: Dynamic Kernel Module Support (where available)
- **Git**: For downloading driver source code
- **Wireless Tools**: For interface management (iw, rfkill)
- **USB Utils**: For device detection
- **Firmware**: Non-free firmware packages

### Distribution-Specific Packages
<details>
<summary>Click to expand package details</summary>

**Debian/Ubuntu-based:**
- `build-essential`
- `linux-headers-$(uname -r)`
- `dkms`, `git`, `wireless-tools`, `iw`, `rfkill`, `usbutils`
- `firmware-misc-nonfree`

**Red Hat/Fedora-based:**
- `gcc`, `make`, `kernel-devel`, `kernel-headers`
- `dkms`, `git`, `wireless-tools`, `iw`, `rfkill`, `usbutils`
- `linux-firmware`

**Arch-based:**
- `base-devel`, `linux-headers`
- `dkms`, `git`, `wireless_tools`, `iw`, `rfkill`, `usbutils`
- `linux-firmware`

**SUSE-based:**
- `gcc`, `make`, `kernel-devel`, `kernel-source`
- `dkms`, `git`, `wireless-tools`, `iw`, `rfkill`, `usbutils`
- `kernel-firmware`

**Alpine:**
- `build-base`, `linux-headers`
- `git`, `wireless-tools`, `iw`, `rfkill`, `usbutils`
- `linux-firmware`
- *Note: DKMS not available on Alpine*

**Void:**
- `gcc`, `make`, `linux-headers`
- `dkms`, `git`, `wireless_tools`, `iw`, `rfkill`, `usbutils`
- `linux-firmware`
</details>

## 📊 LED Control
For supported MediaTek devices, you can control the hardware LED:
```bash
# Turn LED on
./mtkloader.sh led-on
# Turn LED off  
./mtkloader.sh led-off
# Enable LED blinking
./mtkloader.sh led-blink
```

**LED Control Requirements:**
- MT76 driver must be loaded
- Device must support LED control
- debugfs must be mounted (`/sys/kernel/debug`)
- Root privileges required

**Manual debugfs mounting:**
```bash
sudo mount -t debugfs none /sys/kernel/debug
```

## 🔧 Module Configuration
The tool creates module configuration files to optimize performance:

### Module Parameters
Located at `/etc/modprobe.d/mt76_usb.conf`:
```bash
# MT76 USB module configuration
# Disable USB Scatter-Gather if experiencing issues in 5GHz AP mode
# options mt76_usb disable_usb_sg=1
```

### RF-Kill Management
Automatic RF-kill unblocking for wireless devices:
```bash
# Check RF-kill status
rfkill list
# Unblock all RF devices
sudo rfkill unblock all
```

## 📝 Logging
All operations are logged to `/tmp/mtkloader.log` with timestamps:
```bash
# View recent logs
tail -f /tmp/mtkloader.log
# View all logs
cat /tmp/mtkloader.log
```

**Log Format:**
```
HH:MM:SS INFO: Operation started
HH:MM:SS SUCCESS: Driver loaded successfully
HH:MM:SS WARNING: Minor issue detected
HH:MM:SS ERROR: Critical error occurred
```

## 🔧 Troubleshooting
### Common Issues
<details>
<summary>Driver installation fails</summary>

**Possible Causes:**
- Missing kernel headers
- Incompatible kernel version
- Build tools not installed

**Solutions:**
```bash
# Update system first
sudo apt update && sudo apt upgrade  # Debian/Ubuntu
sudo dnf update                      # Fedora/RHEL
# Reinstall kernel headers
sudo apt install linux-headers-$(uname -r)  # Debian/Ubuntu
sudo dnf install kernel-headers kernel-devel # Fedora/RHEL
# Try installation again
./mtkloader.sh install
```
</details>

<details>
<summary>No wireless interfaces detected</summary>

**Diagnosis:**
```bash
# Check USB devices
lsusb | grep -iE "mediatek|0e8d:"
# Check loaded modules
lsmod | grep -E "mt76|mt7612"
# Check interfaces manually
ip link show | grep -E "wlan|wlp|wlx"
```

**Solutions:**
- Ensure device is properly connected
- Try different USB port
- Check if device is supported
- Manually load driver: `sudo modprobe mt76x2u`
</details>

<details>
<summary>Interface won't come up</summary>

**Diagnosis:**
```bash
# Check interface status
./mtkloader.sh status
# Check RF-kill status
rfkill list
# Check kernel messages
dmesg | tail -20
```

**Solutions:**
```bash
# Unblock RF devices
sudo rfkill unblock all
# Manually enable interface
sudo ip link set wlan0 up
# Restart NetworkManager
sudo systemctl restart NetworkManager
```
</details>

<details>
<summary>LED control doesn't work</summary>

**Requirements Check:**
- MT76 driver loaded: `lsmod | grep mt76`
- debugfs mounted: `ls /sys/kernel/debug/`
- PHY device exists: `ls /sys/kernel/debug/ieee80211/`
- Root privileges: Run with `sudo`

**Manual LED Control:**
```bash
# Mount debugfs if needed
sudo mount -t debugfs none /sys/kernel/debug
# Find PHY path
PHY_PATH=$(find /sys/kernel/debug/ieee80211 -name "mt76" -type d | head -1)
# Set register
echo 0x770 | sudo tee "${PHY_PATH}/regidx"
# Turn LED on
echo 0x800000 | sudo tee "${PHY_PATH}/regval"
```
</details>

### Getting Help
1. **Check Logs**: Review `/tmp/mtkloader.log` for detailed error messages
2. **Run Diagnostics**: Use `./mtkloader.sh detect` and `./mtkloader.sh status`
3. **Check System**: Ensure all dependencies are installed
4. **Verify Hardware**: Confirm device compatibility with MediaTek chipsets

## 🔐 Security Considerations
- **Sudo Required**: The script requires `sudo` privileges for system operations
- **Package Installation**: Only installs packages from official repositories
- **Source Compilation**: Downloads driver source from trusted GitHub repository
- **Log Files**: Logs may contain system information - review before sharing

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Test on multiple distributions
4. Submit a pull request

### Development Setup
```bash
# Clone repository
git clone https://github.com/0xb0rn3/mtkdrvlder.git
# Test on different distributions
docker run -it ubuntu:latest bash
docker run -it fedora:latest bash
docker run -it alpine:latest sh
```

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments
- [morrownr/7612u](https://github.com/morrownr/7612u) - MTK 7612U driver source
- MediaTek for hardware documentation
- Linux kernel developers for MT76 framework
- Community contributors and testers

## 📞 Support
- **Issues**: [GitHub Issues](https://github.com/0xb0rn3/mtkdrvlder/issues)
- **Discussions**: [GitHub Discussions](https://github.com/0xb0rn3/mtkdrvlder/discussions)
- **Developer**: [@0xb0rn3](https://github.com/0xb0rn3)

---
**Version**: 0.1.3  
**Last Updated**: June 2025  
**Compatibility**: Linux (Universal)  
**Supported Chipsets**: MT7612U, MT76x2u, MT76 family
