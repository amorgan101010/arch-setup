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
    echo "Syntax: ./format-device.sh DEVICE_PATH [-h]"
    echo "options:"
    echo "-h     Print this Help."
    echo "# Ex: Format a device"
    echo "sudo ./format-device.sh /dev/sdb"
    echo
}

################################################################################
################################################################################
# FormatDevice                                                                 #
################################################################################
################################################################################
FormatDevice()
{
    DEVICE_PATH="$1";
    EFI_PATH="${DEVICE_PATH}1";
    ROOT_PATH="${DEVICE_PATH}3";
    SWAP_PATH="${DEVICE_PATH}2";

    sudo mkfs.fat -F32 "$EFI_PATH"
    sudo mkswap "$SWAP_PATH"
    sudo mkfs.ext4 "$ROOT_PATH"
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
while getopts ":h,U" option; do
    case $option in
        h) # display Help
            Help
            exit;;
        *) # something invalid entered; display Help
            Help
            exit;;
    esac
done

FormatDevice "$@"