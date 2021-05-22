#!/bin/bash

# Usage:
# log CONTEXT MESSAGE
# Where CONTEXT is the name of the caller and
# message is any string.

green=$(tput setaf 2);
reset=$(tput sgr 0);

log() {
    echo -e "(${green}$1${reset}) $2${reset}";
}