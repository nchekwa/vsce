#!/bin/bash
set -euo pipefail

if [ -n "$NGROK_AUTHTOKEN" ]; then
    # Remove old log file if exists
    rm -f /tmp/ngrok.log

    # Start ngrok in background
    ngrok http 20080 --log /tmp/ngrok.log --log-format json &

    # Wait for tunnel to start up (10 seconds)
    echo "Waiting for ngrok tunnel to start..."
    sleep 10

    # Extract tunnel URL from logs
    if command -v jq >/dev/null 2>&1; then
        # Use jq to parse JSON logs and extract URL
        TUNNEL_URL=$(jq -r '.url // empty' /tmp/ngrok.log | grep -v '^$' | tail -1)
    else
        # Fallback: extract URL using grep and sed
        TUNNEL_URL=$(grep '"url"' /tmp/ngrok.log | sed -n 's/.*"url":"\([^"]*\)".*/\1/p' | tail -1)
    fi

    # Save URL to file if found
    if [ -n "$TUNNEL_URL" ]; then
        echo "$TUNNEL_URL" > /home/coder/project/vsce_ngrok.txt
        echo "Ngrok tunnel URL saved to /home/coder/project/vsce_ngrok.txt: $TUNNEL_URL"
        sleep infinity
    else
        echo "Warning: Could not extract tunnel URL from logs"
    fi
else
    echo "Ngrok not configured. Use env NGROK_AUTHTOKEN to set auth-token."
fi
