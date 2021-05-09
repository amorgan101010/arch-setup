#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Mounts the specified device at /mnt, optionally turning on swap. Must be root."
    echo
    echo "Syntax: ./mount.sh [-h|s] DEVICE_PATH"
    echo "options:"
    echo "-h     Print this Help."
    echo "-s     Turn on swap."
    echo
    echo "Ex: Mount a device."
    echo "% sudo ./mount.sh /dev/sdb"
    echo
    echo "Ex: Mount a device and turn on swap."
    echo "% sudo ./mount.sh -s /dev/sdb"
    echo
}

################################################################################
# Mount                                                                         #
################################################################################
Mount()
{
    echo "Received request to mount a device.";

    SWAP="$1";
    DEVICE_PATH="$2";

    # TODO: Don't hardcode partition organization expectations
    EFI_PATH="${DEVICE_PATH}1";
    ROOT_PATH="${DEVICE_PATH}3";
    echo "Mounting partitions of device at /mnt."
    echo "EFI System Partition: $EFI_PATH";
    echo "Root Partition: $ROOT_PATH";

    mount "$ROOT_PATH" /mnt;
    mount "$EFI_PATH" /mnt/efi;

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${DEVICE_PATH}2";
        echo "Turning on swap partition at $SWAP_PATH.";
        swapon "$SWAP_PATH";
    fi;
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program

SWAP=0;
DEVICE_PATH="${*: -1}";

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

Mount "$SWAP" "$DEVICE_PATH";