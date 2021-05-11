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
    echo "Syntax: ./install.sh [-h|sly] DEVICE_PATH"
    echo
    echo "options:"
    echo "-y  Skip prompts."
    echo "-s  Format a swap partition as well as system and root."
    echo "-l  Install minimum recommended packages (base, linux, linux-firmware)."
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
LITE=0;
DEVICE_PATH="${*: -1}";

# TODO1: Add a top-level -y option
while getopts "hsyl" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set SWAP flag
            SWAP_FLAG="s";
            ;;
        l) # Set LITE flag
            LITE=1;
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
#if [ "$LITE" -gt 0 ]
#then
    #pacstrap /mnt base linux linux-firmware grub efibootmgr networkmanager;
#else
    #pacstrap /mnt < ./base-pkglist.txt;
#fi;
pacstrap /mnt base linux linux-firmware;

echo "(prepare-hardware.sh) Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab;

echo "(prepare-hardware.sh) Copying over essential installer files."
cp ./within-chroot.sh /mnt/;
cp ./base-pkglist.txt /mnt/;
cp ./gui-pkglist.txt /mnt/;
cp ./as-user.sh /mnt/;

arch-chroot /mnt ./within-chroot.sh;
