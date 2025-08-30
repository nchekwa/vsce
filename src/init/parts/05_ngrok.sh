#!/bin/bash
set -euo pipefail

if [ -n "$NGROK_AUTHTOKEN" ]; then
    echo "Run ngrok"
    sudo ngrok config add-authtoken "$NGROK_AUTHTOKEN"
else
    echo "Ngrok not configured. Use env NGROK_AUTHTOKEN to set auth-token."
fi
