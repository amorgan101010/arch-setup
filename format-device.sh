#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Format partitions on a device in preparation for installing Arch. Must be root."
    echo
    echo "Syntax: ./format-device.sh [-h|s] DEVICE_PATH"
    echo "options:"
    echo "-h     Print this Help."
    echo "-s     Format a swap partition as well as system and root."
    echo
    echo "# Ex: Format a device with EFI and root"
    echo "sudo ./format-device.sh /dev/sdb"
    echo
    echo "# Ex: Format a device with EFI, root, and swap"
    echo "sudo ./format-device.sh -s /dev/sdb"
    echo
}

################################################################################
################################################################################
# FormatDevice                                                                 #
################################################################################
################################################################################
FormatDevice()
{
    echo "Received request to format a (hopefully) freshly partitioned device.";

    SWAP="$1"
    DEVICE_PATH="$2";

    EFI_PATH="${DEVICE_PATH}1";
    ROOT_PATH="${DEVICE_PATH}3";

    echo "Formatting EFI system partition as FAT32 at $EFI_PATH.";
    #sudo mkfs.fat -F32 "$EFI_PATH"
    echo "Formatting root partition as ext4 at $ROOT_PATH.";
    #sudo mkfs.ext4 "$ROOT_PATH"

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${DEVICE_PATH}2";
        echo "Formatting swap partition at $SWAP_PATH.";
        #sudo mkswap "$SWAP_PATH"
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

FormatDevice "$SWAP" "$DEVICE_PATH"