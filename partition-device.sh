#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Partition a device in preparation for installing Arch. Must be root."
    echo
    echo "Syntax: ./partition-device.sh DEVICE_PATH [-h]"
    echo "options:"
    echo "-h     Print this Help."
    echo "# Ex: Partition a device"
    echo "sudo ./partition-device.sh /dev/sdb"
    echo
}

################################################################################
################################################################################
# PartitionDevice                                                              #
################################################################################
################################################################################
PartitionDevice()
{
    DEVICE_PATH=$1;

    # All of the following should be done by...blocks?
    # IDK, whatever avoids rounding issues and misalignment

    # Figure out size of device
    DEVICE_SIZE=8G;

    # Figure out partition sizes based on device size

    # EFI is probably fine to hard-code
    EFI_SIZE=260M;

    # SWAP should probably be based on disk size
    # Maybe no more than 1/8th total size
    # Min 512M, max of...IDK, whatever is suggested
    SWAP_SIZE=1G;

    # Root should be the remaining space
    # (Not gonna deal with a separate home partition)
    ROOT_SIZE=$DEVICE_SIZE-$EFI_SIZE-$SWAP_SIZE;

    # I am realizing now that this is probably going to be hard
    # and also maybe dangerous to automate...even skipping to
    # scripting filesystem formatting would be a tiny bit safer...
    # Even that could have catastrophic potential, given bad input.
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

PartitionDevice "$@"