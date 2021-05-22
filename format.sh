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
    echo "Format partitions on a device in preparation for installing Arch. Must be root."
    echo
    echo "Syntax: ./format.sh [-swy|h] DEVICE_PATH"
    echo "options:"
    echo "-s  Format a swap partition as well as system and root."
    echo "-w  write changes, rather than just logging intents."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Format a device with EFI and root"
    echo "sudo ./format.sh -wy /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

swap=0;
write=0;
override_prompt=0;

context=$(basename "$0");
device_path="${*: -1}";

while getopts "hswy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap=1;
            ;;
        w) # Set write flag
            write=1;
            ;;
        y) # Skip confirmation prompt
            override_prompt=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

log "$context" "Received request to format partitions on '$device_path'.";

efi_path="${device_path}1";

if [ "$override_prompt" -eq 0 ]
then
    prompt="($context) Enter target path '$device_path' to confirm formatting (-y to skip prompt): ";

    # shellcheck disable=SC2162
    read -p "$prompt" confirmation;
    if [ "$confirmation" != "$device_path" ]
    then
        exit;
    fi;
fi;

log "$context" "Formatting EFI system partition as FAT32 at '$efi_path'.";
if [ "$write" -gt 0 ]; then
    mkfs.fat -F32 "$efi_path";
fi;

if [ "$swap" -gt 0 ]
then
    swap_path="${device_path}2";
    root_path="${device_path}3";

    log "$context" "Formatting swap partition at '$swap_path'.";
    if [ "$write" -gt 0 ]; then
        mkswap "$swap_path";
    fi;
else
    root_path="${device_path}2";
fi;

log "$context" "Formatting root partition as ext4 at '$root_path'.";
if [ "$write" -gt 0 ]; then
    mke2fs -t ext4 -F "$root_path";
fi;

log "$context" "Device formatting complete."
exit;
