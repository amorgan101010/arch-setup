#!/bin/bash

# shellcheck source=lib/log.sh
. ../lib/log.sh

################################################################################
# Help                                                                         #
################################################################################
# Source: https://opensource.com/article/19/12/help-bash-program
Help()
{
    # Display Help
    echo "Converts a directory of non-WAV audio files to WAV with FFmpeg."
    echo
    echo "Syntax: ./convert-to-wav.sh [-w|h] TARGET_DIR_PATH"
    echo "options:"
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "Ex: Convert all OGG and FLAC files in a directory to WAV."
    echo "% ./convert-to-wav.sh -w /mnt/c/Users/Aileen/Desktop/samples/Plasterbrain/arcade-pack"
    echo
}

################################################################################
################################################################################
# Main                                                                         #
################################################################################
################################################################################

write=0;

context=$(basename "$0");

target_dir_path="${*: -1}";

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

log "$context" "Received request to convert audio files to WAV.";

# Go through all the files and convert them to WAVs


for file in "$target_dir_path"/*/*; do
    log "$context" "Converting file $file.";
    if [ "$write" -gt 0 ]; then
        sort "$file";
    fi;
done;
