#!/bin/bash
# slazy.sh – Main entry point for Switch Lazy CLI

# Determine the script’s directory to load our libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/functions.sh"

# Process command‑line arguments
if (( "$#" > 0 )); then
    while [[ "$#" -gt 0 ]]; do
        key="$1"
        case $key in
            -j|--job)
                validate_search_job "$@"
                ;;
            -a|--auth)
                auth
                shift
                ;;
            -c|--config)
                create_conf
                ;;
            -f|--flows)
                list_flows
                ;;
            -p|--ping)
                ping_switch
                ;;
            -h|--help)
                print_help
                ;;
            *)
                printf "Unknown argument \"%s\"\n" "$1"
                printf "Use \"slazy --help\" to see usage information.\n"
                exit 1
                ;;
        esac
    done
else
    # No arguments provided – show summary information.
    printf "\nSwitch: %s\nConfig: %s\nUse \"slazy --help\" to see usage information.\n" "$SWITCH_ADR" "$SLAZY_CF_FILE"
fi