#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Commands to run within an Arch chroot as the newly set up non-root user."
    echo
    echo "Syntax: ./as-user.sh [-h]"
    echo
    echo "options:"
    echo "-h  Print this Help."
    echo
    echo "# Ex: Run commands to prepare user space for movein."
    echo "% sudo ./as-user.sh"
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

echo "(as-user.sh) Retrieving dotfiles.";
cd /home/aileen||exit;
git clone https://github.com/amorgan101010/dotfiles.git /home/aileen/dotfiles;

echo "(as-user.sh) Installing oh-my-zsh and plugins.";
# TODO: specify output location of curled script
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --keep-zshrc --unattended;
git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/aileen/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting;
git clone https://github.com/zsh-users/zsh-autosuggestions /home/aileen/.oh-my-zsh/custom/plugins/zsh-autosuggestions;
cd /home/aileen/dotfiles||exit;
stow oh-my-zsh;
stow vs-code;

echo "(as-user.sh) Building basic AUR helper auracle.";
mkdir /home/aileen/.aur;
cd /home/aileen/.aur||exit;
git clone https://aur.archlinux.org/auracle-git.git /home/aileen/.aur/auracle;
cd /home/aileen/.aur/auracle||exit;
makepkg -si;

# TODO: Add a check for an explicit flag to install yay(?)

echo "(as-user.sh) Set user password.";
passwd aileen;

exit;
