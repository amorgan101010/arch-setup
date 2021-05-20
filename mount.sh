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
    device_path="$2";

    echo "(mount.sh) Received request to mount '$device_path'.";

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${device_path}2";
        ROOT_PATH="${device_path}3";

        echo "(mount.sh) Turning on swap at '$SWAP_PATH'.";
        swapon "$SWAP_PATH";
    else
        ROOT_PATH="${device_path}2";
    fi;

    EFI_PATH="${device_path}1";

    echo "(mount.sh) Mounting partitions of '$device_path' at '/mnt'.";

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
device_path="${*: -1}";

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

Mount "$SWAP" "$device_path";