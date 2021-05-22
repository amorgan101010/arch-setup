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
    echo "Prepares hardware to install Arch and chroot in. Must be root."
    echo
    echo "Syntax: ./prepare-chroot.sh [-swy|h] DEVICE_PATH"
    echo
    echo "options:"
    echo "-s  Format a swap partition as well as system and root."
    echo "-w  write changes, rather than just logging intents."
    echo "-y  Skip prompts."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Prepare a device for installing Arch."
    echo "% sudo ./prepare-chroot.sh -wy /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

BOLD=$(tput bold);
UNFORMAT=$(tput sgr 0);

swap_flag="";
skip_flag="";
write_flag="";

override_prompt=0;

context=$(basename "$0");
device_path="${*: -1}";

while getopts "hswy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        s) # Set swap flag
            swap_flag="s";
            ;;
        w) # Set write flag
            write_flag="w";
            ;;
        y) # Set SKIP flag
            skip_flag="y";
            override_prompt=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done



# TODO: This seems like a good candidate for refactoring into something sourcable
if [ "$override_prompt" -eq 0 ]
then
    prompt="($context) Enter target ${BOLD}$device_path${UNFORMAT} to confirm partitioning and formatting (-y to skip prompt): ";

    # shellcheck disable=SC2162
    read -p "$prompt" confirmation;
    if [ "$confirmation" != "$device_path" ]
    then
        exit;
    fi;

    skip_flag="y";
fi;

log "$context" "Attempting to partition ${BOLD}$device_path${UNFORMAT}.";
./partition.sh "-$swap_flag$write_flag$skip_flag" "$device_path";

log "$context" "Attempting to format ${BOLD}$device_path${UNFORMAT}.";
./format.sh "-$swap_flag$write_flag$skip_flag" "$device_path";

# TODO: Make this configurable
mount_path="/mnt"

log "$context" "Attempting to mount ${BOLD}$device_path${UNFORMAT} to ${BOLD}$mount_path${UNFORMAT}.";
./mount.sh "-$swap_flag$write_flag" "$device_path";

log "$context" "Attempting to bootstrap device with root at ${BOLD}$mount_path${UNFORMAT}."
./bootstrap.sh "-$write_flag" "$mount_path";

log "$context" "Chroot preparations complete."
exit;
