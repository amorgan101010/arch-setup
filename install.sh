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

FLAGS="-$SWAP_FLAG$SKIP_FLAG";

echo "(install.sh) Attempting to install to '$DEVICE_PATH'.";

echo "(install.sh) Attempting to prepare destination with 'prepare-chroot.sh'."
./prepare-chroot.sh "$FLAGS" "$DEVICE_PATH";

echo "(install.sh) Attempting to enter chroot and set up system with 'within-chroot.sh'."
arch-chroot /mnt ./within-chroot.sh;

echo "(install.sh) Time to reboot and see if it works!.";
exit;
