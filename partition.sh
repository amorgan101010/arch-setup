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
    echo "Syntax: ./partition.sh"
    echo "  [-r [ROOT_SIZE]]"
    echo "  [-e [EFI_SIZE]]"
    echo "  [-s [SWAP_SIZE]]"
    echo "  [-H [HOME_SIZE]]"
    echo "  [-h|y] DEVICE_PATH"
    echo
    echo "options:"
    echo "-r  Specify the root partition size in GB."
    echo "-e  Specify the EFI System partition size in MB."
    echo "-H  Create a home directory, optionally specifying size in GB."
    echo "-s  Partition a swap partition as well as system and root, optionally specifying its size in MB."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Partition a device with EFI and root, answering prompts to specify sizes."
    echo "sudo ./partition.sh /dev/sdb"
    echo
    echo "# Ex: Partition a device with EFI and root, specifying sizes and skipping prompts."
    echo "sudo ./partition.sh -e 260 -r 6 /dev/sdb"
    echo
    echo "# Ex: Partition a device with EFI, root, swap, and home."
    echo "sudo ./partition.sh -s -H /dev/sdb"
    echo
}

################################################################################
################################################################################
# Partition                                                                    #
################################################################################
################################################################################
Partition()
{
    echo "Received request to partition a device.";

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

Partition "$SWAP" "$OVERRIDE_PROMPT" "$DEVICE_PATH";