#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Partition a device with GPT in preparation for installing Arch. Must be root."
    echo
    echo "Syntax: ./partition.sh"
    echo "  [-r [ROOT_SIZE]] (not implemented)"
    echo "  [-e [EFI_SIZE]] (not implemented)"
    echo "  [-s [SWAP_SIZE (size specification not implemented)]]"
    echo "  [-H [HOME_SIZE]] (not implemented)"
    echo "  [-h|y] DEVICE_PATH"
    echo
    echo "options:"
    echo "-r  Specify the root partition size in GB."
    echo "-e  Specify the EFI System partition size in MB."
    echo "-H  Create a home directory, optionally specifying size in GB."
    echo "-s  Partition swap as well as system and root, optionally specifying its size in MB."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Partition a device with EFI and root, answering prompts to specify sizes."
    echo "sudo ./partition.sh /dev/sdb"
    echo
    #echo "# Ex: Partition a device with EFI and root, specifying sizes and skipping prompts."
    #echo "sudo ./partition.sh -e 260 -r 6 /dev/sdb"
    #echo
    #echo "# Ex: Partition a device with EFI, root, swap, and home."
    #echo "sudo ./partition.sh -s -H /dev/sdb"
    #echo
}

################################################################################
################################################################################
# Partition                                                                    #
################################################################################
################################################################################
Partition()
{
    SWAP="$1";
    OVERRIDE_PROMPT="$2";
    EFI_SIZE_MB="$3";
    SWAP_SIZE_MB="$4";
    #ROOT_SIZE_GB="$5";
    device_path="${*: -1}";

    echo "(partition.sh) Received request to partition '$device_path'.";

    EFI_PATH="${device_path}1";

    if [ "$OVERRIDE_PROMPT" -eq 0 ]
    then
        PROMPT="(partition.sh) Enter target path '$device_path' to confirm partitioning (use -y to skip prompt): ";

        read -p "$PROMPT" CONFIRMATION;
        if [ "$CONFIRMATION" != "$device_path" ]
        then
            exit;
        fi;
    fi;

    echo "(partition.sh) Removing any existing partitioning from '$device_path'.";
    sgdisk --mbrtogpt "$device_path";
    sgdisk --clear "$device_path";

    echo "(partition.sh) partitioning EFI system partition at '$EFI_PATH'.";
    sgdisk --new=0:0:"$EFI_SIZE_MB"M --typecode=0:EF00 --change-name=0:efi "$device_path";


    if [ "$SWAP" -gt 0 ]
    then
        SWAP_PATH="${device_path}2";
        ROOT_PATH="${device_path}3";

        echo "(partition.sh) Partitioning swap at '$SWAP_PATH'.";
        sgdisk --new=0:0:+"$SWAP_SIZE_MB"M --typecode=0:8200 --change-name=0:swap "$device_path";
    else
        ROOT_PATH="${device_path}2";
    fi;

    echo "(partition.sh) Partitioning root at '$ROOT_PATH'; using remaining disk space.";

    sgdisk --new=0:0:0 --typecode=0:0700 --change-name=0:root "$device_path";
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
SWAP=0;
OVERRIDE_PROMPT=0;
device_path="${*: -1}";

# TODO1: Implement a prompt to override these
# TODO2: Have size suggestions based on device space
EFI_SIZE_MB=550;
SWAP_SIZE_MB=512;

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

# Eventually, the $ROOT_SIZE_GB option will be restored
# probably when home specification is set up
Partition "$SWAP" "$OVERRIDE_PROMPT" "$EFI_SIZE_MB" "$SWAP_SIZE_MB" "$device_path";
