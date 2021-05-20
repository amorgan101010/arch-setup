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
    echo "Syntax: ./install.sh [-swy|h] DEVICE_PATH"
    echo
    echo "options:"
    echo "-s  Format a swap partition as well as system and root."
    echo "-w  write changes, rather than just logging intents."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Installing Arch to a swapless device without confirmation prompts."
    echo "% sudo ./install.sh -wy /dev/sdb"
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

while getopts "hswy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        w) # Set write flag
            write_flag="w";
            write=1;
            ;;
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

# TODO: Replace flags with this as writing flag is implemented in children
flags_with_writing="-$swap_flag$write_flag$skip_flag";

if [ "$write" -gt 0 ]; then
    echo "(install.sh) Changes will be written, potential data loss imminent.";
else
    echo "(install.sh) Changes will NOT be written, logging intents only.";
fi;

echo "(install.sh) Attempting to install to '$device_path'.";

echo "(install.sh) Attempting to prepare destination with 'prepare-chroot.sh'."
./prepare-chroot.sh "$flags_with_writing" "$device_path";


echo "(install.sh) Attempting to enter chroot and set up system with 'within-chroot.sh'."
if [ "$write" -gt 0 ]; then
    arch-chroot /mnt ./within-chroot.sh;
fi;

echo "(install.sh) Time to reboot and see if it worked!.";
exit;
