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
    echo "Syntax: ./prepare-chroot.sh [-swy|h] DEVICE_PATH"
    echo
    echo "options:"
    echo "-s  Format a swap partition as well as system and root."
    echo "-y  Skip prompts."
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Prepare a device for installing Arch."
    echo "% sudo ./prepare-chroot.sh -wy /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

swap_flag="";
skip_flag="";
write_flag="";
write=0;
device_path="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap_flag="s";
            ;;
        w) # Set write flag
            write_flag="w";
            write=1;
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

# TODO: Replace flags with this as writing flag is implemented in children
#flags_with_writing="-$swap_flag$write_flag$skip_flag";

echo "(prepare-chroot.sh) Attempting to partition '$device_path'.";
if [ "$write" -gt 0 ]; then
    ./partition.sh "$flags" "$device_path";
fi;

echo "(prepare-chroot.sh) Attempting to format '$device_path'.";
if [ "$write" -gt 0 ]; then
    ./format.sh "$flags" "$device_path";
fi;

echo "(prepare-chroot.sh) Attempting to mount '$device_path' to '/mnt'.";
if [ "$write" -gt 0 ]; then
    ./mount.sh "$flags" "$device_path";
fi;


if [ "$write" -gt 0 ]; then
    echo "(prepare-chroot.sh) Pacstrapping!"

    pacstrap /mnt base linux linux-firmware;

    echo "(prepare-chroot.sh) Generating fstab."
    genfstab -U /mnt >> /mnt/etc/fstab;

    echo "(prepare-chroot.sh) Copying essential installer files."
    cp ./within-chroot.sh /mnt/;
    cp ./base-pkglist.txt /mnt/;
    cp ./gui-pkglist.txt /mnt/;
    cp ./as-user.sh /mnt/;
fi;

echo "(prepare-chroot.sh) Chroot preparations complete."
exit;
