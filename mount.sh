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
    echo "Syntax: ./mount.sh [-sw|h] DEVICE_PATH"
    echo "options:"
    echo "-s  Turn on swap."
    echo "-w  write changes, rather than just logging intents."
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
################################################################################
# Main                                                                         #
################################################################################
################################################################################

BOLD=$(tput bold);
UNFORMAT=$(tput sgr 0);

swap=0;
write=0;

context=$(basename "$0");
device_path="${*: -1}";

while getopts "hsw" option; do
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
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

# TODO: Make this configurable
mount_path="/mnt"

log "$context" "Received request to mount ${BOLD}$device_path${UNFORMAT} to ${BOLD}$mount_path${UNFORMAT}.";

if [ "$swap" -gt 0 ]
then
    swap_path="${device_path}2";
    root_path="${device_path}3";

    log "$context" "Turning on swap at ${BOLD}$swap_path${UNFORMAT}.";

    if [ "$write" -gt 0 ]; then
        swapon "$swap_path";
    fi;
else
    root_path="${device_path}2";
fi;

efi_path="${device_path}1";

log "$context" "Mounting partitions of ${BOLD}$device_path${UNFORMAT} at ${BOLD}$mount_path${UNFORMAT}.";

if [ "$write" -gt 0 ]; then
    mount "$root_path" "$mount_path";
    mkdir "$mount_path"/efi;
    mount "$efi_path" "$mount_path"/efi;
fi;