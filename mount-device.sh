#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
Help()
{
    # Display Help
    echo "Mount a portable device for use with arch-chroot. Must be root."
    echo
    echo "Syntax: mount-device DEVICE_PATH [-h|U]"
    echo "options:"
    echo "-h     Print this Help."
    echo "-U     Unmount the device at /mnt."
    echo "# Ex: Mount a device"
    echo "sudo ./mount-device.sh /dev/sdb"
    echo "# Ex: Unmount a device"
    echo "sudo ./mount-device.sh /dev/sdb -U"
    echo
}

################################################################################
# Mount                                                                         #
################################################################################
Mount()
{
    # Mount the device partitions to /mnt and turn on swap
    DEVICE_PATH=$1;
    EFI_PATH="${DEVICE_PATH}1";
    ROOT_PATH="${DEVICE_PATH}3";
    SWAP_PATH="${DEVICE_PATH}2";

    mount "$ROOT_PATH" /mnt
    mount "$EFI_PATH" /mnt/efi
    swapon "$SWAP_PATH"
}

################################################################################
# Unmount                                                                         #
################################################################################
Unmount()
{
    # Unmount the device partitions and turn off swap at /mnt
    # I'm making an assumption about the order of arguments
    DEVICE_PATH=$1;
    SWAP_PATH="${DEVICE_PATH}2";

    umount -R /mnt
    swapoff "$SWAP_PATH"
}

################################################################################
################################################################################
# Main script                                                                 #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
while getopts ":h,U" option; do
    case $option in
        h) # display Help
            Help
            exit;;
        U) # attempt to unmount device
            Unmount "$@"
            exit;;
        *) # something invalid entered; display Help
            Help
            exit;;
    esac
done

Mount "$@"