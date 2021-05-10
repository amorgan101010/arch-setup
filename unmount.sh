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
    echo "Syntax: ./unmount.sh [-h|s] [SWAP_PATH]"
    echo "options:"
    echo "-h     Print this Help."
    echo "-s     Use this along with a device partition path to turn off swap."
    echo
    echo "Ex: Unmount a device."
    echo "% sudo ./unmount.sh"
    echo "Ex: Unmount a device and turn off swap."
    echo "% sudo ./unmount.sh -s /dev/sdb2"
    echo
}

################################################################################
# Unmount                                                                         #
################################################################################
Unmount()
{
    echo "Received request to unmount device at /mnt.";

    SWAP="$1";
    SWAP_PATH="$2";

    echo "Unmounting partitions of device at /mnt."
    umount -R /mnt
    if [ "$SWAP" -gt 0 ]
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
SWAP_PATH="${*: -1}";

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