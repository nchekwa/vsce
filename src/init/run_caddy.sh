#!/bin/bash
set -euo pipefail

# Start Caddy only if CADDY_ENABLED is true
if [[ "${CADDY_ENABLED:-false}" == "true" ]]; then
    echo "[run_caddy] CADDY_ENABLED is true. Starting Caddy..."
    exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
else
    echo "[run_caddy] CADDY_ENABLED is not true. Caddy will not be started."
    exit 0
fi
