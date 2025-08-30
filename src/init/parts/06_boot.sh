#!/bin/bash
# Execute optional custom boot script
set -euo pipefail

BOOT_SCRIPT_PATH="${BOOT_INSTALL_SCRIPT:-/home/coder/.config/boot.sh}"
if [ -f "$BOOT_SCRIPT_PATH" ]; then
  echo "Executing custom boot script: $BOOT_SCRIPT_PATH"
  bash "$BOOT_SCRIPT_PATH"
fi
