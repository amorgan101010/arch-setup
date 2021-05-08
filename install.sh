#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Installs Arch. Must be root."
    echo
    echo "Syntax: ./install.sh DEVICE_PATH [-h]"
    echo "options:"
    echo "-h     Print this Help."
    echo "# Ex: Install to a device"
    echo "sudo ./install.sh /dev/sdb"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
while getopts ":h,U" option; do
    case $option in
        h) # display Help
            Help
            exit;;
        *) # something invalid entered; display Help
            Help
            exit;;
    esac
done

DEVICE_PATH="$1"

# Right now, this does nothing
# Do your own dang partitioning!
PartitionDevice "$DEVICE_PATH"