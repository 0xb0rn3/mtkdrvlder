#!/usr/bin/env bash

# MTK Driver Loader v2.0
# Developer: 0xb0rn3
# GitHub: github.com/0xb0rn3/mtkdrvlder
# Enhanced version with improved features and error handling

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_VERSION="2.0"
SCRIPT_NAME="mtkloader.sh"
REPO_URL="https://github.com/morrownr/7612u.git"
REPO_DIR="7612u"
INTERFACE="${INTERFACE:-wlan0}"  # Allow environment override
CONFIG_FILE="${HOME}/.mtkloader_config"
LOG_FILE="/tmp/mtkloader.log"
PERMANENT_POWER=false

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print functions with colors
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO: $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}  MTK Driver Loader v${SCRIPT_VERSION}${NC}"
    echo -e "${PURPLE}  Developer: 0xb0rn3${NC}"
    echo -e "${PURPLE}  GitHub: github.com/0xb0rn3/mtkdrvlder${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. This is not recommended for safety reasons."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Exiting for safety."
            exit 1
        fi
    fi
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        print_info "Configuration loaded from $CONFIG_FILE"
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# MTK Loader Configuration
INTERFACE="$INTERFACE"
PERMANENT_POWER=$PERMANENT_POWER
REPO_URL="$REPO_URL"
EOF
    print_success "Configuration saved to $CONFIG_FILE"
}

# System information
show_system_info() {
    print_info "System Information:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Current User: $(whoami)"
    echo "  Interface: $INTERFACE"
    echo "  Log File: $LOG_FILE"
    echo "  Config File: $CONFIG_FILE"
}

# Check dependencies
check_dependencies() {
    local deps=("git" "make" "gcc" "sudo" "rfkill" "ifconfig")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    print_success "All dependencies are available"
    return 0
}

# Enhanced RF-kill check with detailed status
check_rfkill() {
    print_info "Checking RF-kill status..."
    
    if ! command -v rfkill &> /dev/null; then
        print_warning "rfkill command not found. Skipping RF-kill check."
        return 0
    fi
    
    local rfkill_output
    rfkill_output=$(rfkill list 2>/dev/null || echo "")
    
    if [[ -z "$rfkill_output" ]]; then
        print_info "No RF-kill devices found."
        return 0
    fi
    
    echo "RF-kill Status:"
    echo "$rfkill_output"
    
    if echo "$rfkill_output" | grep -q "blocked: yes"; then
        print_warning "Some RF devices are blocked. Attempting to unblock..."
        if sudo rfkill unblock all; then
            print_success "RF-kill unblock successful."
        else
            print_error "Failed to unblock RF-kill."
            return 1
        fi
    else
        print_success "No RF devices are blocked."
    fi
    
    return 0
}

# Enhanced package installation with progress
install_dependencies() {
    print_info "Updating package lists..."
    if sudo apt update &> /dev/null; then
        print_success "Package lists updated successfully."
    else
        print_error "Failed to update package lists."
        return 1
    fi
    
    local packages=("dkms" "build-essential" "git" "linux-headers-$(uname -r)")
    
    print_info "Installing necessary packages: ${packages[*]}"
    if sudo apt install -y "${packages[@]}"; then
        print_success "All packages installed successfully."
    else
        print_error "Failed to install some packages."
        return 1
    fi
}

# Enhanced driver installation with better error handling
install_driver() {
    print_info "Starting driver installation process..."
    
    # Check if already installed
    if lsmod | grep -q "mt7612u"; then
        print_warning "MT7612U driver appears to be already loaded."
        read -p "Reinstall anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Clean up previous installation
    if [[ -d "$REPO_DIR" ]]; then
        print_info "Removing existing repository directory..."
        rm -rf "$REPO_DIR"
    fi
    
    print_info "Cloning repository from $REPO_URL..."
    if git clone "$REPO_URL"; then
        print_success "Repository cloned successfully."
    else
        print_error "Failed to clone repository."
        return 1
    fi
    
    cd "$REPO_DIR" || {
        print_error "Failed to enter repository directory."
        return 1
    }
    
    # Build and install
    print_info "Building driver..."
    if make; then
        print_success "Driver built successfully."
    else
        print_error "Failed to build driver."
        return 1
    fi
    
    print_info "Installing driver..."
    if sudo make install; then
        print_success "Driver installed successfully."
    else
        print_error "Failed to install driver."
        return 1
    fi
    
    # Load the module
    print_info "Loading driver module..."
    if sudo modprobe mt7612u; then
        print_success "Driver module loaded successfully."
    else
        print_warning "Failed to load driver module automatically."
        print_info "You may need to reboot or manually load the module."
    fi
    
    cd - > /dev/null
}

# Enhanced adapter management
manage_adapter() {
    local action="$1"
    local interface_exists=false
    
    # Check if interface exists
    if ip link show "$INTERFACE" &> /dev/null; then
        interface_exists=true
    fi
    
    if [[ "$interface_exists" == false ]]; then
        print_error "Interface $INTERFACE not found."
        print_info "Available interfaces:"
        ip link show | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/://'
        return 1
    fi
    
    case "$action" in
        enable)
            print_info "Enabling adapter $INTERFACE..."
            if sudo ip link set "$INTERFACE" up; then
                print_success "Adapter $INTERFACE enabled."
                show_interface_status
            else
                print_error "Failed to enable adapter $INTERFACE."
                return 1
            fi
            ;;
        disable)
            print_info "Disabling adapter $INTERFACE..."
            if sudo ip link set "$INTERFACE" down; then
                print_success "Adapter $INTERFACE disabled."
            else
                print_error "Failed to disable adapter $INTERFACE."
                return 1
            fi
            ;;
    esac
}

# Show interface status
show_interface_status() {
    print_info "Interface Status:"
    ip addr show "$INTERFACE" 2>/dev/null || print_warning "Could not get interface details."
    
    # Show wireless info if available
    if command -v iwconfig &> /dev/null; then
        print_info "Wireless Information:"
        iwconfig "$INTERFACE" 2>/dev/null | grep -v "no wireless extensions" || true
    fi
}

# Enhanced LED control with validation
manage_led() {
    local action="$1"
    local phy_path
    
    # Find PHY path dynamically
    phy_path=$(find /sys/kernel/debug/ieee80211 -name "mt76" -type d 2>/dev/null | head -1)
    
    if [[ -z "$phy_path" ]]; then
        print_error "MT76 PHY path not found. Make sure the driver is loaded."
        return 1
    fi
    
    print_info "Using PHY path: $phy_path"
    
    # Set LED register
    if ! echo 0x770 | sudo tee "${phy_path}/regidx" > /dev/null; then
        print_error "Failed to set LED register index."
        return 1
    fi
    
    case "$action" in
        on)
            if echo 0x800000 | sudo tee "${phy_path}/regval" > /dev/null; then
                print_success "LED turned on."
            else
                print_error "Failed to turn on LED."
                return 1
            fi
            ;;
        off)
            if echo 0x820000 | sudo tee "${phy_path}/regval" > /dev/null; then
                print_success "LED turned off."
            else
                print_error "Failed to turn off LED."
                return 1
            fi
            ;;
        blink)
            if echo 0x840000 | sudo tee "${phy_path}/regval" > /dev/null; then
                print_success "LED set to blink."
            else
                print_error "Failed to set LED to blink."
                return 1
            fi
            ;;
    esac
}

# Configuration management
configure_settings() {
    echo
    print_info "Current Configuration:"
    echo "  Interface: $INTERFACE"
    echo "  Permanent Power: $PERMANENT_POWER"
    echo "  Repository URL: $REPO_URL"
    echo
    
    read -p "Change interface name? (current: $INTERFACE) [Enter to keep]: " new_interface
    if [[ -n "$new_interface" ]]; then
        INTERFACE="$new_interface"
    fi
    
    read -p "Enable permanent power? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PERMANENT_POWER=true
    else
        PERMANENT_POWER=false
    fi
    
    save_config
    print_success "Configuration updated."
}

# Driver status check
check_driver_status() {
    print_info "Driver Status Check:"
    
    # Check if module is loaded
    if lsmod | grep -q "mt7612u\|mt76"; then
        print_success "MT76xx driver is loaded."
    else
        print_warning "MT76xx driver is not loaded."
    fi
    
    # Check USB devices
    print_info "USB Wireless Devices:"
    lsusb | grep -i "wireless\|802.11\|wifi" || print_info "No wireless USB devices found."
    
    # Check network interfaces
    print_info "Network Interfaces:"
    ip link show | grep -E "wlan|wlp" || print_info "No wireless interfaces found."
}

# Enhanced menu with more options
display_menu() {
    while true; do
        echo
        print_header
        echo
        echo -e "${CYAN}Main Menu:${NC}"
        echo "1.  Install driver"
        echo "2.  Enable adapter"
        echo "3.  Disable adapter"
        echo "4.  Turn on LED"
        echo "5.  Turn off LED"
        echo "6.  Blink LED"
        echo "7.  Configure settings"
        echo "8.  Check driver status"
        echo "9.  Show interface status"
        echo "10. Check system info"
        echo "11. View logs"
        echo "12. Exit"
        echo
        
        read -p "Enter your choice [1-12]: " choice
        
        case "$choice" in
            1) install_dependencies && install_driver ;;
            2) 
                if [[ "$PERMANENT_POWER" == true ]]; then
                    print_info "Adapter is set to permanent power mode."
                else
                    manage_adapter enable
                fi
                ;;
            3)
                if [[ "$PERMANENT_POWER" == true ]]; then
                    print_info "Adapter is in permanent power mode. Disable not needed."
                else
                    manage_adapter disable
                fi
                ;;
            4) manage_led on ;;
            5) manage_led off ;;
            6) manage_led blink ;;
            7) configure_settings ;;
            8) check_driver_status ;;
            9) show_interface_status ;;
            10) show_system_info ;;
            11) 
                if [[ -f "$LOG_FILE" ]]; then
                    less "$LOG_FILE"
                else
                    print_warning "Log file not found."
                fi
                ;;
            12) 
                print_info "Thank you for using MTK Driver Loader!"
                exit 0
                ;;
            *) print_error "Invalid option. Please try again." ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Command line argument handling
handle_args() {
    case "$1" in
        install) install_dependencies && install_driver ;;
        enable) manage_adapter enable ;;
        disable) manage_adapter disable ;;
        led-on) manage_led on ;;
        led-off) manage_led off ;;
        led-blink) manage_led blink ;;
        configure) configure_settings ;;
        status) check_driver_status ;;
        info) show_system_info ;;
        --help|-h)
            echo "Usage: $0 [OPTION]"
            echo "Options:"
            echo "  install      Install the MTK driver"
            echo "  enable       Enable the wireless adapter"
            echo "  disable      Disable the wireless adapter"
            echo "  led-on       Turn on the LED"
            echo "  led-off      Turn off the LED"
            echo "  led-blink    Make the LED blink"
            echo "  configure    Configure settings"
            echo "  status       Check driver status"
            echo "  info         Show system information"
            echo "  --help, -h   Show this help message"
            echo
            echo "If no option is provided, the interactive menu will be displayed."
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use '$0 --help' for usage information."
            exit 1
            ;;
    esac
}

# Cleanup function
cleanup() {
    print_info "Cleaning up..."
    # Add any cleanup tasks here
}

# Signal handlers
trap cleanup EXIT
trap 'print_error "Script interrupted."; exit 130' INT TERM

# Main execution
main() {
    # Initialize logging
    log "MTK Driver Loader v${SCRIPT_VERSION} started"
    
    # Load configuration
    load_config
    
    # Check if running as root (warn but don't exit)
    check_root
    
    # Check dependencies
    if ! check_dependencies; then
        print_warning "Some dependencies are missing. Install option may fail."
    fi
    
    # Handle command line arguments or show menu
    if [[ $# -eq 0 ]]; then
        display_menu
    else
        handle_args "$1"
    fi
}

# Run main function with all arguments
main "$@"
