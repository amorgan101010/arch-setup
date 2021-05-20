#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Prepares hardware to install Arch and chroot in. Must be root."
    echo
    echo "Syntax: ./prepare-chroot.sh [-h|sy] DEVICE_PATH"
    echo
    echo "options:"
    echo "-y  Skip prompts."
    echo "-s  Format a swap partition as well as system and root."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Prepare a device for installing Arch."
    echo "% sudo ./prepare-chroot.sh /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

swap_flag="";
skip_flag="";
device_path="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap_flag="s";
            ;;
        y) # Set SKIP flag
            skip_flag="y";
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

flags="-$swap_flag$skip_flag"

echo "(prepare-chroot.sh) Attempting to partition '$device_path'.";
./partition.sh "$flags" "$device_path";

echo "(prepare-chroot.sh) Attempting to format '$device_path'.";
./format.sh "$flags" "$device_path";

echo "(prepare-chroot.sh) Attempting to mount '$device_path' to '/mnt'.";
./mount.sh "$flags" "$device_path";

echo "(prepare-chroot.sh) Pacstrapping!"

pacstrap /mnt base linux linux-firmware;

echo "(prepare-chroot.sh) Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab;

echo "(prepare-chroot.sh) Copying essential installer files."
cp ./within-chroot.sh /mnt/;
cp ./base-pkglist.txt /mnt/;
cp ./gui-pkglist.txt /mnt/;
cp ./as-user.sh /mnt/;

echo "(prepare-chroot.sh) Chroot preparations complete."
exit;
