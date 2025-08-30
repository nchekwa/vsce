#!/bin/bash
# Determine auth and start code-server
set -euo pipefail

# Authentication
if [ -n "${PASSWORD:-}" ]; then
  echo "Password authentication enabled"
  AUTH_ARG="--auth password"
else
  echo "No authentication (auth=none)"
  AUTH_ARG="--auth none"
fi

## --cert is ignored / we do SSL using Caddy
CODE_SERVER_ARGS="--user-data-dir=/home/coder/.code/data --extensions-dir=/home/coder/.code/extensions $AUTH_ARG --disable-telemetry --host=0.0.0.0 --port=20080"

# Start code-server
if [ -d "/home/coder/project" ]; then
  echo "Project folder found, using as workspace"
  echo "Starting code-server with: code-server /home/coder/project $CODE_SERVER_ARGS"
  exec code-server /home/coder/project $CODE_SERVER_ARGS
else
  echo "No project folder found, starting without workspace"
  echo "Starting code-server with: $CODE_SERVER_ARGS"
  exec code-server $CODE_SERVER_ARGS
fi
