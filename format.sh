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
    echo "Syntax: ./format.sh [-h|s] DEVICE_PATH"
    echo "options:"
    echo "-h     Print this Help."
    echo "-s     Format a swap partition as well as system and root."
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
# FormatDevice                                                                 #
################################################################################
################################################################################
FormatDevice()
{
    echo "Received request to format a (hopefully) freshly partitioned device.";

    SWAP="$1";
    OVERRIDE_PROMPT="$2";
    DEVICE_PATH="${*: -1}";

    EFI_PATH="${DEVICE_PATH}1";
    ROOT_PATH="${DEVICE_PATH}3";

    if [ "$OVERRIDE_PROMPT" -eq 0 ]
    then
        PROMPT="Enter target path '$DEVICE_PATH' to confirm formatting (use -y to skip prompt): ";

        read -p "$PROMPT" CONFIRMATION;
        if [ "$CONFIRMATION" != "$DEVICE_PATH" ]
        then
            exit;
        fi;
    fi;

    echo "Formatting EFI system partition as FAT32 at $EFI_PATH.";
    #sudo mkfs.fat -F32 "$EFI_PATH";
    echo "Formatting root partition as ext4 at $ROOT_PATH.";
    #sudo mkfs.ext4 "$ROOT_PATH";

    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${DEVICE_PATH}2";
        echo "Formatting swap partition at $SWAP_PATH.";
        #sudo mkswap "$SWAP_PATH";
    fi;
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

FormatDevice "$SWAP" "$OVERRIDE_PROMPT" "$DEVICE_PATH";