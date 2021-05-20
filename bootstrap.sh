#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Pacstraps device with root at '/mnt' and copies install files. Must be root."
    echo
    echo "Syntax: ./bootstrap.sh [-w|h]"
    echo
    echo "options:"
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Pacstrap base packages and copy install files to device."
    echo "% sudo ./bootstrap.sh -w"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

write=0;

while getopts "hw" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        w) # Set write flag
            write=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

echo "(bootstrap.sh) Pacstrapping!"
if [ "$write" -gt 0 ]; then
    pacstrap /mnt base linux linux-firmware;
fi;

echo "(bootstrap.sh) Generating fstab."
if [ "$write" -gt 0 ]; then
    genfstab -U /mnt >> /mnt/etc/fstab;
fi;

echo "(bootstrap.sh) Copying essential installer files."
if [ "$write" -gt 0 ]; then
    cp ./within-chroot.sh /mnt/;
    cp ./base-pkglist.txt /mnt/;
    cp ./gui-pkglist.txt /mnt/;
    cp ./as-user.sh /mnt/;
fi;

echo "(bootstrap.sh) Chroot preparations complete."
exit;
