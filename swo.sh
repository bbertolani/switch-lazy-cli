#!/bin/bash

# shellcheck source="${XDG_CONFIG_HOME:-$HOME/.config}/switchOrchestrator/swo"
# Set default configuration
SWITCH_IP=""
USER=""
HASH_PASS=""
TOKEN=""

# Overwrite default configs from noterc configuration file
SWITCH_CF_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/switchOrchestrator"
SWITCH_CF_FILE="$SWITCH_CF_FOLDER/swo_config"
if [ -f "$SWITCH_CF_FILE" ]; then source "$SWITCH_CF_FILE"; fi
if [ -f "$SWITCH_CF_FOLDER/swo_$SWITCH_IP" ]; then TOKEN=$(cat $SWITCH_CF_FOLDER/swo_$SWITCH_IP); fi

SWITCH_ADR="http://"$SWITCH_IP":51088"

# Help
Help() {
    printf "############################################################
# Help                                                     #
############################################################
Switch Orchestrator
Usage: swo [<args>]
Arguments:
  -h | --help                           Display usage guide.
  -c | --config                         Create config filep
  -a | --auth                           Get token from Switch dont forget the config file
  -j | --job    <JOBNUMBER>             Search about a specific job.
switchOrchestrator loads configuration variables from:
    \$HOME/.config/switchOrchestrator/swo"
    exit 0
}

createConf() {
    # if [ ! -d "$SWITCH_CF_FOLDER" ]; then
    #     echo "Creating config folder in ${SWITCH_CF_FOLDER}..."
    #     exec mkdir $SWITCH_CF_FOLDER
    # fi
    mkdir -p "$SWITCH_CF_FOLDER"

    cd $SWITCH_CF_FOLDER

    if [ -f "$SWITCH_CF_FILE" ]; then
        echo "$SWITCH_CF_FILE exists."
        read -p "Are you sure you want to replace your config? [Yy][Nn]" -n 1 -r
        if [[ $REPLY =~ [^Yy]$ ]]; then
            echo "Install failed"
            break
        fi
        cp $SWITCH_CF_FILE "${SWITCH_CF_FILE}_bkp"
        truncate -s 0 $SWITCH_CF_FILE
    fi

    echo 'USER="XYZ"' >>$SWITCH_CF_FILE
    echo 'HASH_PASS="XXXXXXXXXXXXXXXX"' >>$SWITCH_CF_FILE
    echo 'SWITCH_IP="0.0.0.0"' >>$SWITCH_CF_FILE
    exit 0
}

auth() {
    echo $SWITCH_ADR
    JSON=$(curl -s POST $SWITCH_ADR/login -H 'Content-Type: application/json' -d '{"username": "'$USER'", "password": "'$HASH_PASS'"}')

    result=$(jq -r '.success' <<<$JSON)
    if [ "$result" == "false" ]; then
        echo "Login failed"
        exit 1
    fi
    TOKEN=$(jq -r '.token' <<<$JSON)
    SAVED_TOKEN=$SWITCH_CF_FOLDER/swo_$SWITCH_IP
    touch $SAVED_TOKEN
    truncate -s 0 $SAVED_TOKEN
    echo "$TOKEN" >>$SAVED_TOKEN
    echo "Login Sucessful | SWITCH: $SWITCH_IP"
    checkRequirements
    exit 0
}

searchJob() {
    JSON=$(curl -s --location --request GET "$SWITCH_ADR/api/v1/messages?type=info&type=error&type=warning&type=debug&message=$JOB_NUMBER&limit=100" -H 'Authorization: Bearer '$TOKEN)
    status=$(jq '.status' <<<$JSON)
    if [ "$status" == "success" ]; then
        echo "Search failed OR you're not logged, try to auth again"
        exit 1
    fi
    messages=$(jq '.messages' <<<$JSON)
    echo $messages | jq '[.[] | {type,flow,job,element,message,timestamp}] | sort_by(.timestamp)' | jtbl -d -n
    exit 0
}

validateSearchJob() {
    if [ "$#" -ne 2 ]; then
        printf "Incorrect number of arguments.\n"
        printf "Usage: swo --job <JOBNUMBER>\n"
        exit 1
    fi
    JOB_NUMBER="$2"
    if [ -z "$JOB_NUMBER" ]; then
        printf "Expected additional argument <Job Number>.\n"
        exit 1
    fi
    searchJob $JOB_NUMBER
}

listFlows() {
    JSON=$(curl -s --location --request GET "$SWITCH_ADR/api/v1/flows?fields=status,name,groups" -H 'Authorization: Bearer '$TOKEN)
    messages=$(jq <<<$JSON)
    echo $messages | jq 'map(
        .status |= if . == "stopped" then "\u001b[31m" + . + "\u001b[0m"
                    elif . == "running" then "\u001b[32m" + . + "\u001b[0m"
                    else . end
        | select(.groups | length == 1)
        | .groups |= .[0].name
    ) | sort_by(.groups, .name)' | jtbl -d -n
    exit 0
}

checkRequirements() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Please install it before running this script."
        exit 1
    fi

    if ! command -v jtbl &> /dev/null; then
        echo "jtbl is not installed. Please install it before running this script."
        exit 1
    fi
}

############################################################
# Main program                                             #
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
if (($# > 0)); then
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -j | --job)
            validateSearchJob "$@"
            ;;
        -a | --auth)
            auth
            shift
            ;;
        -c | --config)
            createConf
            ;;
        -f | --flows)
            listFlows
            ;;
        -h | --help)
            Help
            ;;
        *)
            printf "Unknown Argument \"%s\"\n" "$1"
            printf "Use \"swo --help\" to see usage information.\n"
            exit 1
            ;;
        esac
    done
else
    #no arguments/options
    printf "\n
    Switch: $SWITCH_ADR
    Config: $SWITCH_CF_FILE
    Use \"swo --help\" to see usage information.\n"

fi
