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
    echo "Converts a directory of non-WAV audio files to WAV with FFmpeg. Currently supports OGG, FLAC, and MP3."
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


for file in "$target_dir_path"/*; do
    # Clean up file name for logging and validation
    filename=$(basename -- "$file")
    extension="${filename##*.}"
    log "$context" "Considering file $filename for WAV conversion. It has an extension of $extension.";
    #filename="${filename%.*}"
    if [ "$extension" == "ogg" -o "$extension" == "flac" -o "$extension" == "mp3" ]; then
        #output_name_with_old_extension=$(echo "$filename" | awk -F "_" '{print $NF}');
        #output_name_sans_extension=$(echo ${output_name_with_old_extension%.*});
        output_name_sans_extension=$(echo ${filename%.*});
        output_name_with_wav_extension="${output_name_sans_extension}.wav";
        output_name_with_path="$target_dir_path/$output_name_with_wav_extension";

        if [ "$write" -gt 0 ]; then
            log "$context" "Converting $filename to WAV with output name $output_name_with_wav_extension.";
            ffmpeg -i "$file" "$output_name_with_path"
        fi;
    fi;
done;
