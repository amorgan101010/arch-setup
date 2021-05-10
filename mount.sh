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
    echo "Syntax: ./mount.sh [-h|sy] DEVICE_PATH"
    echo "options:"
    echo "-s  Turn on swap."
    echo "-y  Skip prompts (there are none)."
    echo "-h  Print this Help."
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
    SWAP="$1";
    DEVICE_PATH="$2";

    echo "(mount.sh) Received request to mount '$DEVICE_PATH'.";

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${DEVICE_PATH}2";
        ROOT_PATH="${DEVICE_PATH}3";

        echo "(mount.sh) Turning on swap at '$SWAP_PATH'.";
        swapon "$SWAP_PATH";
    else
        ROOT_PATH="${DEVICE_PATH}2";
    fi;

    EFI_PATH="${DEVICE_PATH}1";

    echo "(mount.sh) Mounting partitions of '$DEVICE_PATH' at '/mnt'.";

    mount "$ROOT_PATH" /mnt;
    mkdir /mnt/efi;
    mount "$EFI_PATH" /mnt/efi;
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program

SWAP=0;
DEVICE_PATH="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set SWAP flag
            SWAP=1;
            ;;
        y) # Skip confirmation prompt (meaningless)
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Mount "$SWAP" "$DEVICE_PATH";