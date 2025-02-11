#!/bin/bash
# slazy_config.sh – Loads configuration for Switch Lazy CLI

# Default configuration variables
SLAZY_SWITCH_IP=""
USER=""
HASH_PASS=""
TOKEN=""

# Define configuration folder and file paths
SLAZY_CF_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/slazy"
SLAZY_CF_FILE="$SLAZY_CF_FOLDER/slazy_config"

# Load user configuration if it exists
if [[ -f "$SLAZY_CF_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$SLAZY_CF_FILE"
fi

# If a token file exists for the current SWITCH IP, load it.
if [[ -n "$SLAZY_SWITCH_IP" && -f "$SLAZY_CF_FOLDER/slazy_${SLAZY_SWITCH_IP}" ]]; then
    TOKEN=$(< "$SLAZY_CF_FOLDER/slazy_${SLAZY_SWITCH_IP}")
fi

# Construct the API address (assuming the API port remains unchanged)
SWITCH_ADR="http://${SLAZY_SWITCH_IP}:51088"