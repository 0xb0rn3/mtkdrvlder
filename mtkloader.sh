#!/bin/bash

# MTK Universal Driver Loader v0.1.3
# Developer: 0xb0rn3
# GitHub: github.com/0xb0rn3/mtkdrvlder
# Universal Linux compatibility with auto-detection

set -euo pipefail

# Configuration
SCRIPT_VERSION="0.1.3"
QUIET_MODE=false
LOG_FILE="/tmp/mtkloader.log"
CONFIG_FILE="${HOME}/.mtkloader_config"

# Distribution detection
DISTRO=""
PKG_MANAGER=""
INSTALL_CMD=""
UPDATE_CMD=""

# Hardware detection
DETECTED_INTERFACES=()
DETECTED_DEVICES=()
AUTO_INTERFACE=""

# Simple output functions
log() {
    echo "$(date '+%H:%M:%S') $1" >> "$LOG_FILE"
    [[ "$QUIET_MODE" != true ]] && echo "[$1]"
}

info() {
    log "INFO: $1"
    [[ "$QUIET_MODE" != true ]] && echo "• $1"
}

success() {
    log "SUCCESS: $1"
    [[ "$QUIET_MODE" != true ]] && echo "✓ $1"
}

error() {
    log "ERROR: $1"
    echo "✗ ERROR: $1" >&2
}

warning() {
    log "WARNING: $1"
    [[ "$QUIET_MODE" != true ]] && echo "⚠ $1"
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|elementary|zorin|raspbian)
                DISTRO="debian"
                PKG_MANAGER="apt"
                INSTALL_CMD="apt install -y"
                UPDATE_CMD="apt update"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                DISTRO="redhat"
                PKG_MANAGER="dnf"
                INSTALL_CMD="dnf install -y"
                UPDATE_CMD="dnf check-update"
                ;;
            opensuse*|suse)
                DISTRO="suse"
                PKG_MANAGER="zypper"
                INSTALL_CMD="zypper install -y"
                UPDATE_CMD="zypper refresh"
                ;;
            arch|manjaro|endeavouros|garuda)
                DISTRO="arch"
                PKG_MANAGER="pacman"
                INSTALL_CMD="pacman -S --noconfirm"
                UPDATE_CMD="pacman -Sy"
                ;;
            alpine)
                DISTRO="alpine"
                PKG_MANAGER="apk"
                INSTALL_CMD="apk add"
                UPDATE_CMD="apk update"
                ;;
            gentoo)
                DISTRO="gentoo"
                PKG_MANAGER="emerge"
                INSTALL_CMD="emerge"
                UPDATE_CMD="emerge --sync"
                ;;
            void)
                DISTRO="void"
                PKG_MANAGER="xbps"
                INSTALL_CMD="xbps-install -y"
                UPDATE_CMD="xbps-install -S"
                ;;
            *)
                DISTRO="unknown"
                ;;
        esac
    elif command -v lsb_release &>/dev/null; then
        case "$(lsb_release -si)" in
            Ubuntu|Debian) DISTRO="debian" ;;
            Fedora|RedHat|CentOS) DISTRO="redhat" ;;
            *) DISTRO="unknown" ;;
        esac
    else
        DISTRO="unknown"
    fi
    
    info "Detected: $DISTRO ($PKG_MANAGER)"
}

# Check if driver is already available in kernel
check_kernel_driver() {
    # Check if mt76x2u module is available (in-kernel since 4.19)
    if modinfo mt76x2u &>/dev/null; then
        success "MT76x2u driver available in kernel"
        return 0
    elif modinfo mt7612u &>/dev/null; then
        success "MT7612u driver available in kernel"
        return 0
    else
        info "Kernel driver not found, will need to compile"
        return 1
    fi
}

# Load kernel module
load_kernel_module() {
    local modules=("mt76x2u" "mt7612u" "mt76_usb" "mt76")
    
    for module in "${modules[@]}"; do
        if modinfo "$module" &>/dev/null; then
            info "Loading module: $module"
            if sudo modprobe "$module" &>/dev/null; then
                success "Module $module loaded"
                return 0
            fi
        fi
    done
    
    warning "Could not load any MTK modules"
    return 1
}

# Universal package installation
install_package() {
    local package="$1"
    case "$DISTRO" in
        debian)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD build-essential ;;
                "kernel-headers") sudo $INSTALL_CMD linux-headers-$(uname -r) ;;
                "dkms") sudo $INSTALL_CMD dkms ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless-tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD firmware-misc-nonfree || true ;;
            esac
            ;;
        redhat)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD gcc make kernel-devel ;;
                "kernel-headers") sudo $INSTALL_CMD kernel-headers kernel-devel ;;
                "dkms") sudo $INSTALL_CMD dkms ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless-tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD linux-firmware || true ;;
            esac
            ;;
        arch)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD base-devel ;;
                "kernel-headers") sudo $INSTALL_CMD linux-headers ;;
                "dkms") sudo $INSTALL_CMD dkms ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless_tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD linux-firmware || true ;;
            esac
            ;;
        suse)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD gcc make kernel-devel ;;
                "kernel-headers") sudo $INSTALL_CMD kernel-source ;;
                "dkms") sudo $INSTALL_CMD dkms ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless-tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD kernel-firmware || true ;;
            esac
            ;;
        alpine)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD build-base ;;
                "kernel-headers") sudo $INSTALL_CMD linux-headers ;;
                "dkms") warning "DKMS not available on Alpine" ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless-tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD linux-firmware || true ;;
            esac
            ;;
        void)
            case "$package" in
                "build-tools") sudo $INSTALL_CMD gcc make ;;
                "kernel-headers") sudo $INSTALL_CMD linux-headers ;;
                "dkms") sudo $INSTALL_CMD dkms ;;
                "git") sudo $INSTALL_CMD git ;;
                "wireless-tools") sudo $INSTALL_CMD wireless_tools iw rfkill ;;
                "usb-utils") sudo $INSTALL_CMD usbutils ;;
                "firmware") sudo $INSTALL_CMD linux-firmware || true ;;
            esac
            ;;
    esac
}

# Auto-detect wireless hardware
detect_hardware() {
    info "Scanning for wireless hardware..."
    
    # Clear previous detections
    DETECTED_INTERFACES=()
    DETECTED_DEVICES=()
    
    # Detect USB wireless devices
    if command -v lsusb &>/dev/null; then
        local usb_devices
        usb_devices=$(lsusb 2>/dev/null || echo "")
        while IFS= read -r line; do
            if echo "$line" | grep -qiE "wireless|802\.11|wifi|realtek|mediatek|ralink|atheros|broadcom|0e8d:"; then
                DETECTED_DEVICES+=("USB: $line")
            fi
        done <<< "$usb_devices"
    fi
    
    # Detect PCI wireless devices
    if command -v lspci &>/dev/null; then
        local pci_devices
        pci_devices=$(lspci 2>/dev/null | grep -iE "wireless|802\.11|wifi|network" || echo "")
        while IFS= read -r line; do
            [[ -n "$line" ]] && DETECTED_DEVICES+=("PCI: $line")
        done <<< "$pci_devices"
    fi
    
    # Detect network interfaces
    if command -v ip &>/dev/null; then
        local interfaces
        interfaces=$(ip link show 2>/dev/null | grep -E "wlan|wlp|wlx" | cut -d: -f2 | tr -d ' ' || echo "")
        while IFS= read -r iface; do
            [[ -n "$iface" ]] && DETECTED_INTERFACES+=("$iface")
        done <<< "$interfaces"
    fi
    
    # Fallback to iwconfig
    if [[ ${#DETECTED_INTERFACES[@]} -eq 0 ]] && command -v iwconfig &>/dev/null; then
        local iw_output
        iw_output=$(iwconfig 2>/dev/null | grep -E "^[a-z]" | cut -d' ' -f1 || echo "")
        while IFS= read -r iface; do
            [[ -n "$iface" ]] && DETECTED_INTERFACES+=("$iface")
        done <<< "$iw_output"
    fi
    
    # Set auto interface
    if [[ ${#DETECTED_INTERFACES[@]} -gt 0 ]]; then
        AUTO_INTERFACE="${DETECTED_INTERFACES[0]}"
        success "Auto-detected interface: $AUTO_INTERFACE"
    else
        warning "No wireless interfaces detected"
        AUTO_INTERFACE="wlan0"
    fi
    
    # Show detected hardware
    if [[ ${#DETECTED_DEVICES[@]} -gt 0 ]]; then
        info "Detected wireless devices:"
        printf "  %s\n" "${DETECTED_DEVICES[@]}"
    fi
    
    if [[ ${#DETECTED_INTERFACES[@]} -gt 0 ]]; then
        info "Detected interfaces:"
        printf "  %s\n" "${DETECTED_INTERFACES[@]}"
    fi
}

# Detect MTK devices specifically
detect_mtk_devices() {
    local mtk_found=false
    
    # Check for MTK USB devices (MediaTek vendor ID: 0e8d)
    if command -v lsusb &>/dev/null; then
        if lsusb | grep -qiE "mediatek|0e8d:"; then
            success "MediaTek USB device detected"
            mtk_found=true
        fi
    fi
    
    # Check for loaded MTK modules
    if lsmod | grep -qE "mt76|mt7612|mt76x2u"; then
        success "MTK driver already loaded"
        mtk_found=true
    fi
    
    return $mtk_found
}

# Universal dependency installation
install_dependencies() {
    info "Installing dependencies for $DISTRO..."
    
    # Update package manager
    case "$DISTRO" in
        debian|redhat|suse|arch|void)
            info "Updating package lists..."
            sudo $UPDATE_CMD &>/dev/null || warning "Failed to update package lists"
            ;;
    esac
    
    # Install core dependencies
    local deps=("build-tools" "kernel-headers" "git" "wireless-tools" "usb-utils" "firmware")
    [[ "$DISTRO" != "alpine" ]] && deps+=("dkms")
    
    for dep in "${deps[@]}"; do
        info "Installing $dep..."
        install_package "$dep" || warning "Failed to install $dep"
    done
    
    success "Dependencies installed"
}

# Install driver from source (fallback if kernel doesn't have it)
install_driver_source() {
    local repo_url="https://github.com/morrownr/7612u.git"
    local repo_dir="7612u"
    
    info "Installing MTK driver from source..."
    
    # Clean previous installation
    [[ -d "$repo_dir" ]] && rm -rf "$repo_dir"
    
    # Clone repository
    if ! git clone "$repo_url" "$repo_dir" &>/dev/null; then
        error "Failed to clone driver repository"
        return 1
    fi
    
    cd "$repo_dir" || return 1
    
    # Make executable
    chmod +x install-driver.sh
    
    # Install driver using the repo's install script
    info "Running installation script..."
    if ! sudo ./install-driver.sh; then
        error "Failed to install driver"
        cd - &>/dev/null
        return 1
    fi
    
    cd - &>/dev/null
    rm -rf "$repo_dir"
    
    success "Driver installation complete"
}

# Universal driver installation
install_driver() {
    # First try to use kernel module if available
    if check_kernel_driver; then
        if load_kernel_module; then
            success "Using in-kernel driver"
            return 0
        fi
    fi
    
    # Fall back to source installation
    install_driver_source
}

# Configure module parameters (disable scatter-gather if needed)
configure_module_params() {
    local conf_file="/etc/modprobe.d/mt76_usb.conf"
    
    if [[ ! -f "$conf_file" ]]; then
        info "Creating module configuration..."
        echo "# MT76 USB module configuration" | sudo tee "$conf_file" > /dev/null
        echo "# Disable USB Scatter-Gather if experiencing issues in 5GHz AP mode" | sudo tee -a "$conf_file" > /dev/null
        echo "# options mt76_usb disable_usb_sg=1" | sudo tee -a "$conf_file" > /dev/null
        success "Module configuration created at $conf_file"
    fi
}

# Universal interface management
manage_interface() {
    local action="$1"
    local interface="${2:-$AUTO_INTERFACE}"
    
    if ! ip link show "$interface" &>/dev/null; then
        error "Interface $interface not found"
        return 1
    fi
    
    case "$action" in
        up)
            info "Enabling $interface..."
            sudo ip link set "$interface" up &>/dev/null
            success "Interface $interface enabled"
            ;;
        down)
            info "Disabling $interface..."
            sudo ip link set "$interface" down &>/dev/null
            success "Interface $interface disabled"
            ;;
        status)
            echo "Interface status for $interface:"
            ip addr show "$interface" 2>/dev/null | head -3
            if command -v iwconfig &>/dev/null; then
                iwconfig "$interface" 2>/dev/null | head -5
            fi
            ;;
    esac
}

# Universal LED control (fixed path detection)
control_led() {
    local action="$1"
    local phy_path
    
    # Find PHY path - try multiple possible locations
    for path in /sys/kernel/debug/ieee80211/phy*/mt76; do
        if [[ -d "$path" ]]; then
            phy_path="$path"
            break
        fi
    done
    
    if [[ -z "$phy_path" ]]; then
        error "MT76 PHY not found - driver may not be loaded or debugfs not mounted"
        error "Try: sudo mount -t debugfs none /sys/kernel/debug"
        return 1
    fi
    
    # Set register
    echo "0x770" | sudo tee "${phy_path}/regidx" &>/dev/null
    
    case "$action" in
        on) echo "0x800000" | sudo tee "${phy_path}/regval" &>/dev/null ;;
        off) echo "0x820000" | sudo tee "${phy_path}/regval" &>/dev/null ;;
        blink) echo "0x840000" | sudo tee "${phy_path}/regval" &>/dev/null ;;
    esac
    
    success "LED $action"
}

# RF-kill management
manage_rfkill() {
    if ! command -v rfkill &>/dev/null; then
        warning "rfkill not available"
        return 0
    fi
    
    if rfkill list | grep -q "blocked: yes"; then
        info "Unblocking RF devices..."
        sudo rfkill unblock all
        success "RF devices unblocked"
    else
        info "RF devices already unblocked"
    fi
}

# Quick setup mode
quick_setup() {
    info "MTK Universal Driver Loader v$SCRIPT_VERSION"
    info "Quick setup mode - minimal interaction"
    
    detect_distro
    detect_hardware
    
    if detect_mtk_devices; then
        info "MTK device already configured"
        manage_rfkill
        if [[ -n "$AUTO_INTERFACE" ]]; then
            manage_interface up "$AUTO_INTERFACE"
        fi
        return 0
    fi
    
    info "Setting up MTK driver..."
    install_dependencies
    install_driver
    configure_module_params
    manage_rfkill
    
    # Give modules time to load
    sleep 2
    
    # Re-detect hardware after driver installation
    detect_hardware
    
    if [[ -n "$AUTO_INTERFACE" ]]; then
        manage_interface up "$AUTO_INTERFACE"
    fi
    
    success "Setup complete!"
    info "Interface: $AUTO_INTERFACE"
    info "Use: $0 led-on|led-off|led-blink for LED control"
    info "Use: $0 status to check system status"
}

# Show system status
show_status() {
    echo "=== MTK Driver Status ==="
    
    detect_distro
    detect_hardware
    
    echo
    echo "Loaded MTK modules:"
    lsmod | grep -E "mt76|mt7612" || echo "  No MTK modules loaded"
    
    echo
    echo "MTK USB devices:"
    lsusb | grep -iE "mediatek|0e8d:" || echo "  No MTK USB devices found"
    
    echo
    echo "Wireless interfaces:"
    if [[ ${#DETECTED_INTERFACES[@]} -gt 0 ]]; then
        for iface in "${DETECTED_INTERFACES[@]}"; do
            manage_interface status "$iface"
            echo
        done
    else
        echo "  No wireless interfaces found"
    fi
    
    echo "RF-kill status:"
    if command -v rfkill &>/dev/null; then
        rfkill list
    else
        echo "  rfkill not available"
    fi
}

# Minimal menu
show_menu() {
    echo
    echo "MTK Driver Loader v$SCRIPT_VERSION"
    echo "1. Quick Setup (Auto)"
    echo "2. Install Driver"
    echo "3. Enable Interface"
    echo "4. LED On"
    echo "5. LED Off"
    echo "6. LED Blink"
    echo "7. Status"
    echo "8. Configure Module Parameters"
    echo "9. Exit"
    echo
    read -p "Choice [1-9]: " choice
    
    case "$choice" in
        1) quick_setup ;;
        2) detect_distro && install_dependencies && install_driver ;;
        3) detect_hardware && manage_interface up ;;
        4) control_led on ;;
        5) control_led off ;;
        6) control_led blink ;;
        7) show_status ;;
        8) configure_module_params ;;
        9) exit 0 ;;
        *) error "Invalid choice" ;;
    esac
}

# Command line handling
handle_command() {
    case "$1" in
        quick|auto|setup) quick_setup ;;
        install) detect_distro && install_dependencies && install_driver ;;
        enable) detect_hardware && manage_interface up ;;
        disable) detect_hardware && manage_interface down ;;
        led-on) control_led on ;;
        led-off) control_led off ;;
        led-blink) control_led blink ;;
        status) show_status ;;
        detect) detect_distro && detect_hardware ;;
        config) configure_module_params ;;
        -q|--quiet) QUIET_MODE=true; quick_setup ;;
        -h|--help)
            echo "MTK Universal Driver Loader v$SCRIPT_VERSION"
            echo "Usage: $0 [command]"
            echo
            echo "Commands:"
            echo "  quick/auto/setup  - Automatic setup (recommended)"
            echo "  install          - Install driver only"
            echo "  enable           - Enable interface"
            echo "  disable          - Disable interface"
            echo "  led-on           - Turn LED on"
            echo "  led-off          - Turn LED off"
            echo "  led-blink        - Blink LED"
            echo "  status           - Show detailed status"
            echo "  detect           - Detect hardware"
            echo "  config           - Configure module parameters"
            echo "  -q, --quiet      - Quiet mode"
            echo "  -h, --help       - Show help"
            echo
            echo "No command = Interactive menu"
            echo
            echo "Note: This script supports MT7612U chipset devices."
            echo "Modern Linux kernels (4.19+) include the mt76x2u driver."
            ;;
        *) error "Unknown command: $1" && exit 1 ;;
    esac
}

# Main execution
main() {
    # Initialize log
    echo "MTK Loader v$SCRIPT_VERSION - $(date)" > "$LOG_FILE"
    
    # Check sudo availability
    if ! command -v sudo &>/dev/null; then
        error "sudo required but not found"
        exit 1
    fi
    
    # Check if debugfs is mounted (needed for LED control)
    if [[ ! -d /sys/kernel/debug ]]; then
        warning "debugfs not mounted - LED control may not work"
        info "To enable: sudo mount -t debugfs none /sys/kernel/debug"
    fi
    
    # Handle arguments
    if [[ $# -eq 0 ]]; then
        while true; do
            show_menu
            echo
            read -p "Continue? (y/n): " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && break
        done
    else
        handle_command "$1"
    fi
}

# Run main with all arguments
main "$@"
