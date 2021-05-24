#!/bin/bash

# shellcheck source=lib/log.sh
. lib/log.sh

#########################yy#######################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Installs Arch Linux, just the way I like it. Must be root."
    echo
    echo "Syntax: ./($context) [-gmswy|h] DEVICE_PATH"
    echo
    echo "options:"
    echo "-g  Install a GUI."
    echo "-m  Use BIOS/MBR rather than UEFI/GPT." # Will I ever support BIOS/GPT?
    echo "-s  Format a swap partition as well as system and root."
    echo "-w  write changes, rather than just logging intents."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Installing Arch to a swapless device without confirmation prompts."
    echo "% sudo ./($context) -gwy /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

BOLD=$(tput bold);
UNFORMAT=$(tput sgr 0);

mbr_flag="";
swap_flag="";
skip_flag="";
write_flag="";
gui_flag="";

write=0;

context=$(basename "$0");
device_path="${*: -1}";

while getopts "ghmswy" option; do
    case $option in
        g) # Set gui flag
            gui_flag="g";
            ;;
        m) # Set mbr flag
            mbr_flag="m";
            ;;
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

if [ "$write" -gt 0 ]; then
    red=$(tput setaf 1);
    log "$context" "${red}Changes WILL BE WRITTEN, potential data loss imminent.";
else
    yellow=$(tput setaf 3);
    log "$context" "${yellow}Changes will NOT be written, logging intents only.";
fi;

log "$context" "Attempting to install to ${BOLD}$device_path${UNFORMAT}.";

log "$context" "Attempting to prepare destination with ${BOLD}prepare-chroot.sh${UNFORMAT}."
./prepare-chroot.sh "-$mbr_flag$swap_flag$write_flag$skip_flag" "$device_path";

log "$context" "Attempting to enter chroot and set up system with ${BOLD}within-chroot.sh${UNFORMAT}."
if [ "$write" -gt 0 ]; then
    arch-chroot /mnt /arch-setup/within-chroot.sh "-$gui_flag";
fi;

# TODO: Call unmount.sh

log "$context" "Time to reboot and see if it worked!";
exit;
