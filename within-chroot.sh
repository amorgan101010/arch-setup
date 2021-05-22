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
    echo "Syntax: ./within-chroot.sh [-g|h]"
    echo
    echo "options:"
    echo "-g  Install a GUI."
    echo "-h  Print this Help."
    echo
    echo "# Ex: Run commands to prepare new GUI'd Arch install from within."
    echo "% sudo ./within-chroot.sh -g"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

gui=0;

while getopts "gh" option; do
    case $option in
        g) # Set gui bool
            gui=1;
            ;;
        h) # display Help
            Help;
            exit;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac
done

echo "(within-chroot.sh) Setting up locale.";

sed -i '1,/en_US.UTF-8 UTF-8/!{s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/}' /etc/locale.gen;

locale-gen;

echo "LANG=en_US.UTF-8" >> /etc/locale.conf;

echo "(within-chroot.sh) Setting time zone.";
ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime;

echo "(within-chroot.sh) Setting up hosts and hostname.";

# TODO: Allow passing in the name as a variable
# AND/OR have a prompt
host_name="FreshArch";
echo "$host_name" >> /etc/hostname;

{
    echo "127.0.0.1 localhost";
    echo "::1 localhost";
    echo "127.0.1.1 $host_name.localdomain $host_name";
} >> /etc/hosts;

echo "(within-chroot.sh) Installing non-GUI base packages.";
# Ignore comments
grep -v "^#" /arch-setup/base-pkglist.txt | pacman -S --noconfirm --needed -;

echo "(within-chroot.sh) Installing GRUB to EFI partition.";
# TODO: Flag to specify removable
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --removable;

echo "(within-chroot.sh) Gnerating GRUB config.";
grub-mkconfig -o /boot/grub/grub.cfg;

echo "(within-chroot.sh) Enabling NetworkManager service.";
systemctl enable NetworkManager.service;

echo "(within-chroot.sh) Set root password.";
passwd;

echo "(within-chroot.sh) Granting superuser to members of wheel.";
echo -e "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/99_wheel;

if [ "$gui" -gt 0 ]; then
    echo "(within-chroot.sh) Installing X Windows System, GNOME DE, and misc graphical software.";

    # Ignore comments
    grep -v "^#" /arch-setup/gui-pkglist.txt | pacman -S --noconfirm --needed -;

    echo "(within-chroot.sh) Enabling Greeter.";
    systemctl enable gdm.service;
fi;

# TODO: Make this configurable
# This'll require making it configurable in the next script...maybe?
# No, in the next script I can use the env var "$USER"
user_name="aileen";

echo "(within-chroot.sh) Creating default non-root user.";
useradd --create-home --shell /usr/bin/zsh --groups wheel,games,audio "$user_name";

echo "(within-chroot.sh) Running user script as non-root user.";
su - "$user_name" -c "/bin/bash /arch-setup/as-user.sh";

echo "(within-chroot.sh) Please set non-root user password."
passwd $user_name;

echo "(within-chroot.sh) Actions within chroot complete."
exit;
