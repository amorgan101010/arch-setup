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
    echo "Mounts the specified device at /mnt, optionally turning on swap. Must be root."
    echo
    echo "Syntax: ./mount.sh [-h|sy] DEVICE_PATH"
    echo "options:"
    echo "-s  Turn on swap."
    echo "-y  Skip prompts (there are none)."
    echo "-h  Print this Help."
    echo
    echo "Ex: Mount a device."
    echo "% sudo ./mount.sh /dev/sdb"
    echo
    echo "Ex: Mount a device and turn on swap."
    echo "% sudo ./mount.sh -s /dev/sdb"
    echo
}

################################################################################
# Mount                                                                         #
################################################################################
Mount()
{
    swap="$1";
    device_path="$2";

    log "$context" "Received request to mount '$device_path'.";

    if [ "$swap" -gt 0 ]
    then
        swap_path="${device_path}2";
        root_path="${device_path}3";

        log "$context" "Turning on swap at '$swap_path'.";
        swapon "$swap_path";
    else
        root_path="${device_path}2";
    fi;

    efi_path="${device_path}1";

    log "$context" "Mounting partitions of '$device_path' at '/mnt'.";

    mount "$root_path" /mnt;
    mkdir /mnt/efi;
    mount "$efi_path" /mnt/efi;
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program

swap=0;
context=$(basename "$0");
device_path="${*: -1}";

while getopts "hsy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap=1;
            ;;
        y) # Skip confirmation prompt (meaningless)
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

Mount "$swap" "$device_path";