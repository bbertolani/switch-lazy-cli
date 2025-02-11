#!/bin/bash
# slazy_functions.sh – Functions for Switch Lazy CLI

# Display help/usage information.
print_help() {
    cat <<EOF
############################################################
# Help                                                     #
############################################################
Switch Lazy CLI
Usage: slazy [<args>]
Arguments:
  -h | --help                           Display this help message.
  -c | --config                         Create or replace the config file.
  -a | --auth                           Get token from Switch (ensure your config is set up).
  -j | --job    <JOBNUMBER>             Search for a specific job.
  -f | --flows                         List flows.
  -p | --ping                          Ping the Switch API.
Switch Lazy CLI loads configuration variables from:
    \$HOME/.config/slazy/slazy_config
EOF
    exit 0
}

# Create a configuration file interactively.
create_conf() {
    local response
    mkdir -p "$SLAZY_CF_FOLDER" || { echo "Failed to create config folder."; exit 1; }
    cd "$SLAZY_CF_FOLDER" || { echo "Failed to change directory to config folder."; exit 1; }

    if [[ -f "$SLAZY_CF_FILE" ]]; then
        echo "Config file already exists at $SLAZY_CF_FILE."
        read -r -p "Are you sure you want to replace your config? [y/N]: " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Config creation aborted."
            exit 1
        fi
        cp "$SLAZY_CF_FILE" "${SLAZY_CF_FILE}_bkp" || { echo "Failed to backup config file."; exit 1; }
        # Truncate the config file safely
        : > "$SLAZY_CF_FILE"
    fi

    {
        echo 'USER="XYZ"'
        echo 'HASH_PASS="XXXXXXXXXXXXXXXX"'
        echo 'SLAZY_SWITCH_IP="0.0.0.0"'
    } >> "$SLAZY_CF_FILE" || { echo "Failed to write to config file."; exit 1; }

    # Set secure permissions (read/write for owner only)
    chmod 600 "$SLAZY_CF_FILE" || echo "Warning: Could not set secure permissions on config file."

    echo "Configuration file created at $SLAZY_CF_FILE."
    exit 0
}

# Authenticate with the Switch API.
auth() {
    check_requirements
    local json token_file
    echo "Attempting authentication against $SWITCH_ADR..."
    json=$(curl -s --fail --max-time 5 -X POST "$SWITCH_ADR/login" \
      -H 'Content-Type: application/json' \
      -d "{\"username\": \"${USER}\", \"password\": \"${HASH_PASS}\"}") || {
        echo "Login failed: Timeout or network error."
        exit 1
    }

    if [[ $(jq -r '.success' <<< "$json") != "true" ]]; then
        echo "Login failed: Invalid credentials or error in response."
        exit 1
    fi

    TOKEN=$(jq -r '.token' <<< "$json")
    token_file="$SLAZY_CF_FOLDER/slazy_${SLAZY_SWITCH_IP}"
    # Set a restrictive umask so that the token file is not world-accessible
    umask 077
    echo "$TOKEN" > "$token_file" || { echo "Failed to write token file."; exit 1; }
    chmod 600 "$token_file" || echo "Warning: Could not set secure permissions on token file."
    echo "Login successful | SWITCH: $SLAZY_SWITCH_IP"
    check_requirements
    exit 0
}

# Search for a job with a given job number.
search_job() {
    local job_number="$1"
    check_requirements
    local json status messages
    json=$(curl -s --fail --max-time 10 --get --data-urlencode "message=${job_number}" \
           "$SWITCH_ADR/api/v1/messages?type=info&type=error&type=warning&type=debug&limit=100" \
           -H "Authorization: Bearer ${TOKEN}") || {
        echo "Search job failed: Timeout or network error."
        exit 1
    }
    status=$(jq -r '.status' <<< "$json")
    if [[ "$status" == "success" ]]; then
        echo "Search failed OR you're not logged in. Try authenticating again."
        exit 1
    fi
    messages=$(jq '.messages' <<< "$json")
    echo "$messages" | jq '[.[] | {type, flow, job, element, message, timestamp}] | sort_by(.timestamp)' | jtbl -d -n
    exit 0
}

# Validate that a job number argument is provided, then search.
validate_search_job() {
    if [[ "$#" -lt 2 ]]; then
        echo "Incorrect number of arguments."
        echo "Usage: slazy --job <JOBNUMBER>"
        exit 1
    fi
    local job_number="$2"
    if [[ -z "$job_number" ]]; then
        echo "Expected additional argument <JOBNUMBER>."
        exit 1
    fi
    search_job "$job_number"
}

# List flows from the Switch API.
list_flows() {
    check_requirements
    local json messages
    json=$(curl -s --fail --max-time 5 "$SWITCH_ADR/api/v1/flows?fields=status,name,groups" \
         -H "Authorization: Bearer ${TOKEN}") || {
        echo "List flows failed: Timeout or network error."
        exit 1
    }
    messages=$(jq '.' <<< "$json")
    echo "$messages" | jq 'map(
        .status |= if . == "stopped" then "\u001b[31m" + . + "\u001b[0m"
                    elif . == "running" then "\u001b[32m" + . + "\u001b[0m"
                    else . end
        | select(.groups | length == 1)
        | .groups |= .[0].name
    ) | sort_by(.groups, .name)' | jtbl -d -n
    exit 0
}

# Ping the Switch API.
ping_switch() {
    check_requirements
    local json output status
    json=$(curl -s --fail --max-time 5 "$SWITCH_ADR/api/v1/ping" \
         -H "Authorization: Bearer ${TOKEN}") || {
        echo "Ping failed: Timeout or network error."
        exit 1
    }
    output=$(jq '.' <<< "$json")
    if [[ $(jq -r '.data' <<< "$output") == "1" ]]; then
        echo "Unauthorized / Not Available / Not Reachable"
        echo "Note: The Switch API may not be available, but the Switch App might be running."
        auth
    fi
    status=$(jq -r '.status' <<< "$output")
    echo "--------------------------------"
    echo "Switch API Status: $status"
    echo "--------------------------------"
    exit 0
}

# Check that required commands are installed.
check_requirements() {
    for cmd in jq jtbl curl; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Required command '$cmd' is not installed. Please install it and try again."
            exit 1
        fi
    done
}