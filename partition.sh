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
    echo "Partition a device in preparation for installing Arch. Must be root."
    echo "Defaults to creating a UEFI/GPT setup with EFI and root partitions."
    echo
    echo "Syntax: ./partition.sh [-mswy|h] DEVICE_PATH"
    #echo "  [-r [ROOT_SIZE]] (not implemented)"
    #echo "  [-e [EFI_SIZE]] (not implemented)"
    #echo "  [-s [SWAP_SIZE (size specification not implemented)]]"
    #echo "  [-H [HOME_SIZE]] (not implemented)"
    echo
    echo "options:"
    echo "-m  Use BIOS/MBR rather than UEFI/GPT."
    echo "-s  Partition swap as well as system and root."
    echo "-w  write changes, rather than just logging intents."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    #echo "-r  Specify the root partition size in GB."
    #echo "-e  Specify the EFI System partition size in MB."
    #echo "-H  Create a home directory, optionally specifying size in GB."
    #echo "-s  Partition swap as well as system and root, optionally specifying its size in MB."
    echo
    echo "# Ex: Partition a device with EFI and root."
    echo "sudo ./partition.sh -y /dev/sdb"
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
# Main                                                                         #
################################################################################
################################################################################

BOLD=$(tput bold);
UNFORMAT=$(tput sgr 0);

mbr=0;
write=0;
swap=0;
override_prompt=0;

context=$(basename "$0");
device_path="${*: -1}";

# TODO1: Implement a prompt to override these
# TODO2: Have size suggestions based on device space
efi_size_mb=549;
swap_size_mb=512;

while getopts "hmswy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        m) # Set mbr flag
            mbr=1;
            ;;
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

# Eventually, the $ROOT_SIZE_GB option will be restored
# probably when home specification is set up
#Partition "$swap" "$override_prompt" "$efi_size_mb" "$swap_size_mb" "$device_path";

log "$context" "Received request to partition ${BOLD}$device_path${UNFORMAT}.";


if [ "$override_prompt" -eq 0 ]
then
    prompt="($context) Enter target path ${BOLD}$device_path${UNFORMAT} to confirm partitioning (use -y to skip prompt): ";

    # I can't figure out how to address this warning...
    # shellcheck disable=SC2162
    read -p "$prompt" confirmation;
    if [ "$confirmation" != "$device_path" ]
    then
        exit;
    fi;
fi;

log "$context" "Removing any existing partitioning from ${BOLD}$device_path${UNFORMAT}.";
if [ "$write" -gt 0 ]; then
    wipefs --all "$device_path";

    if [ "$mbr" -eq 0 ]; then
        sgdisk --mbrtogpt "$device_path";
        sgdisk --clear "$device_path";
    else
        echo "I should do MBR here...";
    fi;
fi;


if [ "$mbr" -eq 0 ]; then
    efi_path="${device_path}1";

    log "$context" "partitioning EFI system partition at ${BOLD}$efi_path${UNFORMAT}.";
    if [ "$write" -gt 0 ]; then
        sgdisk --new=0:0:"$efi_size_mb"M --typecode=0:EF00 --change-name=0:efi "$device_path";
    fi;
fi;

if [ "$swap" -gt 0 ]
then
    if [ "$mbr" -eq 0 ]; then
        swap_path="${device_path}2";
        root_path="${device_path}3";

        log "$context" "Partitioning swap at ${BOLD}$swap_path${UNFORMAT}.";
        if [ "$write" -gt 0 ]; then
            sgdisk --new=0:0:+"$swap_size_mb"M --typecode=0:8200 --change-name=0:swap "$device_path";
        fi;
    else
        swap_path="${device_path}2";
        root_path="${device_path}3";

        log "$context" "Partitioning swap at ${BOLD}$swap_path${UNFORMAT}.";
        if [ "$write" -gt 0 ]; then
            sfdisk "$device_path";
        fi;
    fi;

else
    if [ "$mbr" -eq 0 ]; then
        root_path="${device_path}2";
    else
        root_path="${device_path}1";
    fi;
fi;

log "$context" "Partitioning root at ${BOLD}$root_path${UNFORMAT} using remaining disk space.";
if [ "$write" -gt 0 ]; then
    sgdisk --new=0:0:0 --typecode=0:0700 --change-name=0:root "$device_path";
fi;

log "$context" "Device partitioning complete."
exit;
