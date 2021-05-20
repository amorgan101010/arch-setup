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
    echo "Syntax: ./within-chroot.sh [-h]"
    echo
    echo "options:"
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

while getopts "hy" option; do
    case $option in
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

echo "TargetArch" >> /etc/hostname;

{
    echo "127.0.0.1 localhost";
    echo "::1 localhost";
    echo "127.0.1.1 TargetArch.localdomain TargetArch";
} >> /etc/hosts;

echo "(within-chroot.sh) Installing non-GUI base packages.";
# Ignore comments
grep -v "^#" /base-pkglist.txt | pacman -S --noconfirm --needed -;

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

echo "(within-chroot.sh) Creating default non-root user.";
useradd --create-home --shell /usr/bin/zsh --groups wheel,games,audio aileen;

echo "(within-chroot.sh) Installing X Windows System, GNOME DE, and misc graphical software.";

# Ignore comments
grep -v "^#" /gui-pkglist.txt | pacman -S --noconfirm --needed -;

echo "(within-chroot.sh) Enabling Greeter.";
systemctl enable gdm.service;

echo "(within-chroot.sh) Running user script.";
su - aileen -c "/bin/bash /as-user.sh";

echo "(within-chroot.sh) Time to reboot and see if it works!.";
exit;
