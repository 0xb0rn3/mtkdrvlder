MTK Loader Script

This script is designed to manage a wireless adapter, including driver installation, enabling/disabling the adapter, and controlling the LED indicator. It supports various operations and provides an interactive menu for ease of use.
Features

    Install Driver: Clone a GitHub repository, install necessary packages, and build the driver using DKMS.
    Enable/Disable Adapter: Turn the wireless adapter on or off.
    LED Control: Control the LED indicator of the wireless adapter (turn on, turn off, or blink).
    RF-Kill Check: Check and unblock the RF-kill status if the adapter is blocked.

Requirements

    Operating System: Linux
    Packages: dkms, build-essential, git (will be installed by the script if not already present)
    Permissions: sudo access required for various operations

Usage
Interactive Menu

To run the script and use the interactive menu:

bash

./mtkloader.sh

You will be presented with a menu to choose from various options:

    Install Driver: Clones the repository and installs the driver.
    Enable Adapter: Enables the wireless adapter.
    Disable Adapter: Disables the wireless adapter.
    Turn on LED: Turns on the LED indicator.
    Turn off LED: Turns off the LED indicator.
    Blink LED: Sets the LED indicator to blink.
    Exit: Exits the script.

Command-Line Options

You can also run the script with specific commands:

    Install Driver:

    bash

./mtkloader.sh install

Enable Adapter:

bash

./mtkloader.sh enable

Disable Adapter:

bash

./mtkloader.sh disable

Turn on LED:

bash

./mtkloader.sh led-on

Turn off LED:

bash

./mtkloader.sh led-off

Blink LED:

bash

    ./mtkloader.sh led-blink

Script Functions

    check_rfkill: Checks and unblocks RF-kill if the wireless interface is blocked.
    install_dependencies: Updates package lists and installs required packages.
    install_driver: Clones the repository, builds, and installs the driver.
    enable_adapter: Enables the wireless adapter.
    disable_adapter: Disables the wireless adapter.
    set_led_register: Sets the LED control register.
    led_on: Turns on the LED indicator.
    led_off: Turns off the LED indicator.
    led_blink: Makes the LED indicator blink.

Notes

    Replace wlan0 in the INTERFACE variable with the actual name of your wireless interface if different.
    Ensure that the install-driver.sh script exists in the cloned repository and is executable.
    The PHY_PATH is derived dynamically; ensure that the path is valid for your system.

License

This script is provided as-is. Use it at your own risk.
