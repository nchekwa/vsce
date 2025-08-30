#!/bin/bash
# Ensure user-data-dir and extensions-dir exist
set -euo pipefail

if [ ! -d "/home/coder/.code/data" ] || [ ! -d "/home/coder/.code/extensions" ]; then
    echo "Creating user-data-dir and extensions-dir"
    mkdir -p /home/coder/.code/data
    mkdir -p /home/coder/.code/extensions
fi
