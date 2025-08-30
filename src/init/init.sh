#!/bin/bash

# Orchestrator mode: run modular parts and exit
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Inline shared library: parse_config_file
parse_config_file() {
    local file_path=$1
    local valid_entries=""

    if [ -f "$file_path" ]; then
        echo "Reading configuration from $file_path"
        while IFS= read -r line || [ -n "$line" ]; do
            if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
                continue
            fi
            entry=$(echo "$line" | awk '{print $1}')
            if [ -n "$entry" ]; then
                valid_entries="$valid_entries $entry"
            fi
        done < "$file_path"
    fi

    echo "$valid_entries"
}

# Export function so parts run via bash can use it
export -f parse_config_file

echo "[init] Running modular install parts from $SCRIPT_DIR/parts"
for part in "$SCRIPT_DIR/parts/"[0-9][0-9]_*.sh; do
    if [ -f "$part" ]; then
        echo "-------------------------------------"
        echo "[init] Executing: $(basename "$part")"
        echo "-------------------------------------"
        bash "$part"
    fi
done
echo "[init] All parts completed"
exit 0