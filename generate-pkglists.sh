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
    echo "Sorts and converts categorical pkglists into groups expected by the installer."
    echo
    echo "Syntax: ./generate-pkglists.sh [-gw|h]"
    echo "options:"
    #echo "-a  Include AUR packages in the generated list."
    echo "-g  Include GUI packages in the generated list."
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "Ex: Generate pkglist for installer including GUI packages."
    echo "% ./generate-pkglists.sh -gw"
    echo
}

################################################################################
################################################################################
# Merge                                                                        #
################################################################################
################################################################################

Merge()
{
    category_dir=$1;
    dest_filename=$2;
    past_first_pass=0;

    for category in "$category_dir"/*; do
        suffixless=$(basename "$category" .pkglist);
        capitalized="${suffixless^}";

        {
            if [ "$past_first_pass" -gt 0 ]; then
                echo;
            else
                past_first_pass=1;
            fi;
            echo "# $capitalized";
            echo;
            cat "$category";
            echo;
        } >> "$dest_filename";
    done;
}

################################################################################
################################################################################
# Sort                                                                         #
################################################################################
################################################################################

Sort()
{
    dir="$pkglists_dir";

    for file in "$dir"/*/*; do
        log "$context" "Sorting file $file.";
        if [ "$write" -gt 0 ]; then
            sort "$file";
        fi;
    done;
}


################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

gui=0;
write=0;

context=$(basename "$0");

while getopts "dhgw" option; do
    case $option in
        h) # display Help
            Help;
            exit;;
        w) # Write changes rather than logging intents
            write=1;
            ;;
        *) # something invalid entered; display Help
            Help;
            exit;;
    esac;
done;

log "$context" "Received request to generate a pkglist for installation.";

# Sort all the individual pkglists, even if they're not part of this run

pkglists_dir=./pkglists;
base_dir="$pkglists_dir"/base;
gui_dir="$pkglists_dir"/gui;

Sort;

# Combine categories into files with comments based on the individual pkglist file names

base_filename="$pkglists_dir"/base.pkglist.test;
gui_filename="$pkglists_dir"/gui.pkglist.test;

log "$context" "Removing old pkglists.";
if [ "$write" -gt 0 ]; then
    rm -f $base_filename $gui_filename;
fi;

log "$context" "Generating base.pkglist.";
Merge $base_dir $base_filename;

log "$context" "Generating gui.pkglist.";
if [ "$gui" -gt 0 ]; then
    Merge $gui_dir $gui_filename;
fi;

log "$context" "Pkglist generation complete.";
