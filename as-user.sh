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
    echo "% ./as-user.sh"
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
cd "$HOME"||exit;
git clone https://github.com/amorgan101010/dotfiles.git "$HOME"/dotfiles;

echo "(as-user.sh) Installing oh-my-zsh and plugins.";
# TODO: specify output location of curled script
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended;
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting;
git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions;
rm "$HOME"/.zshrc;
cd "$HOME"/dotfiles||exit;
stow oh-my-zsh;
stow vs-code;

# Still not working after adding dependencies...
#echo "(as-user.sh) Building basic AUR helper auracle.";
#mkdir "$HOME"/.aur;
#cd "$HOME"/.aur||exit;
#git clone https://aur.archlinux.org/auracle-git.git "$HOME"/.aur/auracle;
#cd "$HOME"/.aur/auracle||exit;
#makepkg -si;

# TODO: Add a check for an explicit flag to install yay(?)

#echo "(as-user.sh) Set user password.";
#passwd;

echo "(as-user.sh) Actions as user complete."
exit;
