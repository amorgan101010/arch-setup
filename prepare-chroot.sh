#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Prepares hardware to install Arch. Must be root."
    echo
    echo "Syntax: ./install.sh [-h|sy] DEVICE_PATH"
    echo
    echo "options:"
    echo "-y  Skip prompts."
    echo "-s  Format a swap partition as well as system and root."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Prepare a device for installing Arch."
    echo "% sudo ./install.sh /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

SWAP_FLAG="";
SKIP_FLAG="";
DEVICE_PATH="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set SWAP flag
            SWAP_FLAG="s";
            ;;
        y) # Set SKIP flag
            SKIP_FLAG="y";
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

FLAGS="-$SWAP_FLAG$SKIP_FLAG"

echo "(prepare-hardware.sh) Attempting to partition '$DEVICE_PATH'.";
./partition.sh "$FLAGS" "$DEVICE_PATH";

echo "(prepare-hardware.sh) Attempting to format '$DEVICE_PATH'.";
./format.sh "$FLAGS" "$DEVICE_PATH";

echo "(prepare-hardware.sh) Attempting to mount '$DEVICE_PATH' to '/mnt'.";
./mount.sh "$FLAGS" "$DEVICE_PATH";

echo "(prepare-hardware.sh) Pacstrapping!"

pacstrap /mnt base linux linux-firmware;

echo "(prepare-hardware.sh) Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab;

echo "(prepare-hardware.sh) Copying over essential installer files."
cp ./within-chroot.sh /mnt/;
cp ./base-pkglist.txt /mnt/;
cp ./gui-pkglist.txt /mnt/;
cp ./as-user.sh /mnt/;

arch-chroot /mnt ./within-chroot.sh;
