#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Commands to run within a freshly set up Arch chroot. Must be root."
    echo
    echo "Syntax: ./within-chroot.sh [-h|y]"
    echo
    echo "options:"
    echo "-y  Skip prompts."
    echo "-s  Format a swap partition as well as system and root."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Run commands to prepare new Arch install from within."
    echo "% sudo ./within-chroot.sh"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

SKIP_FLAG="";
DEVICE_PATH="${*: -1}";

# TODO1: Add a top-level -y option
while getopts "hy" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        y) # Set SKIP flag
            SKIP_FLAG="y";
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

FLAGS="-$SKIP_FLAG"

echo "(within-chroot.sh) Doing chroot stuff.";
