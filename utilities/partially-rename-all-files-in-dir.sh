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
    echo "Partially renames all files in a given directory, preserving part of the name."
    echo "Currently a single-use script for renaming some samples with long names."
    echo
    echo "Syntax: ./partially-rename-all-files-in-dir.sh [-w|h] TARGET_DIR_PATH"
    echo "options:"
    echo "-w  write changes, rather than just logging intents."
    echo "-h  Print this Help."
    echo
    echo "Ex: Rename all files in a directory like 'DWP-MnM-[unique-sample-name].wav'."
    echo "% ./partially-rename-all-files-in-dir.sh -w /mnt/c/Users/Aileen/Desktop/samples/DENZELWORLDPEACE_MONOMACHINE_SAMPLES"
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

log "$context" "Received request to rename all files in directory.";

# Declare constants
extension=".wav";
abbreviated_leader="DWP-MnM-";

# Go through all the files and rename them
for file in "$target_dir_path"/*; do
    # Clean up file name for logging and validation
    filename=$(basename -- "$file");

    log "$context" "Considering file $filename for renaming.";

    long_filename_sans_extension=$(echo ${filename%.*});

    # split extensionless filename by dashes
    # Based on: https://stackoverflow.com/q/918886
    # and https://stackoverflow.com/a/918931
    IFS='-' read -ra filename_split_by_dashes <<< "$long_filename_sans_extension";

    #filename_split_by_dashes=$long_filename_sans_extension;
    log "$context" "Here's the unique part of the filename: ${filename_split_by_dashes[-1]}";

    # Remaining steps:
    # 1. Get part of filename after the last dash.

    # 1.1 Optionally remove whitespace from unique portion of filename.
    # Doing this mandates the IFS stuff be inside the for loop, I think.

    # 2. Attach it to my abbreviated leader.

    # 3. Stick the extension back on to the reformatted string.

    # 4. `cp`/`mv` old file to new name.
    # 4.1 (I'm a little nervous to use `mv` for this).
    # 4.2 Yeah, I'll use `cp` and delete the old files after...

    # Done! Move on to next file.

    output_name_with_wav_extension="${long_filename_sans_extension}.wav";
    output_name_with_path="$target_dir_path/$output_name_with_wav_extension";

    if [ "$write" -gt 0 ]; then
        log "$context" "Duplicating $filename to WAV with reformatted name $output_name_with_wav_extension.";
        #ffmpeg -i "$file" "$output_name_with_path"
    fi;
done;
