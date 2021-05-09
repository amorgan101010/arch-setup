#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Unmounts the device at /mnt, optionally turning off swap at a given device path. Must be root."
    echo
    echo "Syntax: ./unmount-device.sh [-h|s] [DEVICE_PATH]"
    echo "options:"
    echo "-h     Print this Help."
    echo "-s     Use this along with a device partition path to turn off swap."
    echo
    echo "Ex: Unmount a device."
    echo "% sudo ./unmount-device.sh"
    echo "Ex: Unmount a device and turn off swap."
    echo "% sudo ./unmount-device.sh -s /dev/sdb2"
    echo
}

################################################################################
# Unmount                                                                         #
################################################################################
Unmount()
{
    echo "Received request to unmount an Arch device.";

    USB_DEVICE="$1";
    SWAP_PATH="$2";

    echo "Unmounting partitions of device at /mnt."
    umount -R /mnt
    if [ "$USB_DEVICE" -gt 0 ]
    then
        echo "Turning off swap partition of device at $SWAP_PATH.";
        swapoff "$SWAP_PATH";
    fi
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program

# Booleans? Where we're going, we don't need booleans...
# ...what streaming service is that trilogy on?
# Sick, Netflix!
SWAP=0;
SWAP_PATH="$2";

while getopts ":h:s" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set SWAP flag
            SWAP=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Unmount "$SWAP" "$SWAP_PATH";