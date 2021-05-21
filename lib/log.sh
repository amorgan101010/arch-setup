#!/bin/bash

# Usage:
# log CONTEXT MESSAGE
# Where CONTEXT is the name of the caller and
# message is any string.
log() {
    echo "($1) $2";
}