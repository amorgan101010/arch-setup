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
pacman -S --noconfirm - < /base-pkglist.txt;

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
pacman -S --noconfirm - < /gui-pkglist.txt;

echo "(within-chroot.sh) Enabling Greeter.";
sudo systemctl enable gdm.service;

echo "(within-chroot.sh) Retrieving dotfiles.";
cd /home/aileen||exit;
su - aileen -c "git clone https://github.com/amorgan101010/dotfiles.git /home/aileen/dotfiles";

echo "(within-chroot.sh) Installing oh-my-zsh and plugins.";
# TODO: specify output location of curled script
su - aileen -c "sh -c \"$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\" \"\" --keep-zshrc --unattended";
su - aileen -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/aileen/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting";
su - aileen -c "git clone https://github.com/zsh-users/zsh-autosuggestions /home/aileen/.oh-my-zsh/custom/plugins/zsh-autosuggestions";
cd /home/aileen/dotfiles||exit;
su - aileen -c "stow oh-my-zsh";

echo "(within-chroot.sh) Building basic AUR helper auracle.";
su - aileen -c "mkdir /home/aileen/.aur";
cd /home/aileen/.aur||exit;
su - aileen -c "git clone https://aur.archlinux.org/auracle-git.git /home/aileen/.aur";
cd /home/aileen/.aur/auracle-git||exit;
su - aileen -c "makepkg -si";

# TODO: Add a check for an explicit flag to install yay(?)

echo "(within-chroot.sh) Set user password.";
passwd aileen;

echo "(within-chroot.sh) Time to reboot and see if it works!.";
exit;