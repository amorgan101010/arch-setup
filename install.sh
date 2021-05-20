#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Installs Arch Linux, just the way I like it. Must be root."
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
        y) # Set skip flag
            skip_flag="y";
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

flags="-$swap_flag$skip_flag";

echo "(install.sh) Attempting to install to '$device_path'.";

echo "(install.sh) Attempting to prepare destination with 'prepare-chroot.sh'."
./prepare-chroot.sh "$flags" "$device_path";

echo "(install.sh) Attempting to enter chroot and set up system with 'within-chroot.sh'."
arch-chroot /mnt ./within-chroot.sh;

echo "(install.sh) Time to reboot and see if it works!.";
exit;
