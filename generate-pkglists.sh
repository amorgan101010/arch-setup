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
    echo "Syntax: ./generate-pkglists.sh [-w|h]"
    echo "options:"
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "Ex: Generate sorted and combined pkglists."
    echo "% ./generate-pkglists.sh -w"
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
# Main                                                                         #
################################################################################
################################################################################

write=0;

context=$(basename "$0");

while getopts "hw" option; do
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

# Alphabetize packages in all the individual pkglists

pkglists_dir=./pkglists;

for file in "$pkglists_dir"/*/*; do
    log "$context" "Sorting file $file.";
    if [ "$write" -gt 0 ]; then
        sort "$file";
    fi;
done;

# Combine categories into files with comments based on the individual pkglist file names

base_dir="$pkglists_dir"/base;
gui_dir="$pkglists_dir"/gui;
base_filename="$pkglists_dir"/base.pkglist.test;
gui_filename="$pkglists_dir"/gui.pkglist.test;

log "$context" "Removing old pkglists.";
if [ "$write" -gt 0 ]; then
    rm -f $base_filename $gui_filename;
fi;

log "$context" "Generating base.pkglist.";
Merge $base_dir $base_filename;

log "$context" "Generating gui.pkglist.";
Merge $gui_dir $gui_filename;

# TODO: Something with the AUR?

log "$context" "Pkglist generation complete.";
