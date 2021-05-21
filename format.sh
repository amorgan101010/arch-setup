#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Format partitions on a device in preparation for installing Arch. Must be root."
    echo
    echo "Syntax: ./format.sh [-h|sy] DEVICE_PATH"
    echo "options:"
    echo "-s  Format a swap partition as well as system and root."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Format a device with EFI and root"
    echo "sudo ./format.sh /dev/sdb"
    echo
    echo "# Ex: Format a device with EFI, root, and swap"
    echo "sudo ./format.sh -s -y /dev/sdb"
    echo
}

################################################################################
################################################################################
# Format
################################################################################
################################################################################
Format()
{
    swap="$1";
    override_prompt="$2";
    context=$(basename "$0");
    device_path="${*: -1}";

    log "$context" "Received request to format partitions on '$device_path'.";

    efi_path="${device_path}1";

    if [ "$override_prompt" -eq 0 ]
    then
        prompt="($context) Enter target path '$device_path' to confirm formatting (use -y to skip prompt): ";

        # shellcheck disable=SC2162
        read -p "$prompt" confirmation;
        if [ "$confirmation" != "$device_path" ]
        then
            exit;
        fi;
    fi;

    log "$context" "Formatting EFI system partition as FAT32 at '$efi_path'.";
    sudo mkfs.fat -F32 "$efi_path";

    if [ "$swap" -gt 0 ]
    then
        swap_path="${device_path}2";
        root_path="${device_path}3";

        log "$context" "Formatting swap partition at '$swap_path'.";
        sudo mkswap "$swap_path";
    else
        root_path="${device_path}2";
    fi;

    log "$context" "Formatting root partition as ext4 at '$root_path'.";
    sudo mke2fs -t ext4 -F "$root_path";
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

swap=0;
override_prompt=0;
device_path="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap=1;
            ;;
        y) # Skip confirmation prompt
            override_prompt=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Format "$swap" "$override_prompt" "$device_path";