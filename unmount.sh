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
    echo "Syntax: ./unmount.sh [-h|s] [swap_path]"
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

    swap="$1";
    swap_path="$2";

    echo "Unmounting partitions of device at /mnt."
    umount -R /mnt
    if [ "$swap" -gt 0 ]
    then
        echo "Turning off swap partition of device at $swap_path.";
        swapoff "$swap_path";
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
swap=0;
swap_path="${*: -1}";

while getopts ":h:s" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Unmount "$swap" "$swap_path";