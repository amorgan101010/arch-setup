#!/bin/bash

# shellcheck source=lib/log.sh
. lib/log.sh

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Pacstraps device with root at 'MOUNT_PATH' and copies install files. Must be root."
    echo
    echo "Syntax: ./bootstrap.sh [-w|h] MOUNT_PATH"
    echo
    echo "options:"
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Pacstrap base packages and copy install files to device."
    echo "% sudo ./bootstrap.sh -w /mnt"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

BOLD=$(tput bold);
UNFORMAT=$(tput sgr 0);

write=0;
context=$(basename "$0");
mount_path="${*: -1}";

while getopts "hw" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        w) # Set write flag
            write=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

log "$context" "Pacstrapping ${BOLD}$mount_path${UNFORMAT}."
if [ "$write" -gt 0 ]; then
    pacstrap "$mount_path" base linux linux-firmware;
fi;

log "$context" "Generating fstab."
if [ "$write" -gt 0 ]; then
    genfstab -U "$mount_path" >> "$mount_path"/etc/fstab;
fi;

log "$context" "Copying essential installer files."
if [ "$write" -gt 0 ]; then
    mkdir "$mount_path"/arch-setup;
    cp -r . "$mount_path"/arch-setup;
fi;

log "$context" "Chroot preparations complete."
exit;
