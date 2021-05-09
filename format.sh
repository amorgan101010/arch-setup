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
    echo "(format.sh) Received request to format a (hopefully) freshly partitioned device.";

    SWAP="$1";
    OVERRIDE_PROMPT="$2";
    DEVICE_PATH="${*: -1}";

    EFI_PATH="${DEVICE_PATH}1";

    if [ "$OVERRIDE_PROMPT" -eq 0 ]
    then
        PROMPT="(format.sh) Enter target path '$DEVICE_PATH' to confirm formatting (use -y to skip prompt): ";

        read -p "$PROMPT" CONFIRMATION;
        if [ "$CONFIRMATION" != "$DEVICE_PATH" ]
        then
            exit;
        fi;
    fi;

    echo "(format.sh) Formatting EFI system partition as FAT32 at '$EFI_PATH'.";
    sudo mkfs.fat -F32 "$EFI_PATH";

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${DEVICE_PATH}2";
        ROOT_PATH="${DEVICE_PATH}3";

        echo "(format.sh) Formatting swap partition at '$SWAP_PATH'.";
        sudo mkswap "$SWAP_PATH";
    else
        ROOT_PATH="${DEVICE_PATH}2";
    fi;

    echo "(format.sh) Formatting root partition as ext4 at '$ROOT_PATH'.";
    sudo mkfs.ext4 "$ROOT_PATH";
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
SWAP=0;
OVERRIDE_PROMPT=0;
DEVICE_PATH="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set SWAP flag
            SWAP=1;
            ;;
        y) # Skip confirmation prompt
            OVERRIDE_PROMPT=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Format "$SWAP" "$OVERRIDE_PROMPT" "$DEVICE_PATH";