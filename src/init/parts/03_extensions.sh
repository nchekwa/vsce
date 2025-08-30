#!/bin/bash
# Install code-server extensions from env var INSTALL_EXTENSIONS and/or /home/coder/.config/extensions.txt
set -euo pipefail


EXTENSIONS_TO_INSTALL=""

if [ -n "${INSTALL_EXTENSIONS:-}" ]; then
  echo -e "Found extensions in environment variable:\n${INSTALL_EXTENSIONS}"
  CLEANED_EXTENSIONS=$(echo "${INSTALL_EXTENSIONS}" | tr '\n' ' ')
  CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//\"/}"
  CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//,/ }"
  CLEANED_EXTENSIONS=$(echo "${CLEANED_EXTENSIONS}" | sed -e 's/[[:space:]]\+/ /g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  EXTENSIONS_TO_INSTALL="$EXTENSIONS_TO_INSTALL $CLEANED_EXTENSIONS"
fi

EXTENSIONS_CONFIG_FILE="/home/coder/.config/extensions.txt"
if [ -f "$EXTENSIONS_CONFIG_FILE" ]; then
  CONFIG_EXTENSIONS=$(parse_config_file "$EXTENSIONS_CONFIG_FILE")
  EXTENSIONS_TO_INSTALL="$EXTENSIONS_TO_INSTALL $CONFIG_EXTENSIONS"
fi

if [ -n "$EXTENSIONS_TO_INSTALL" ]; then
  echo "Final extensions to install: $EXTENSIONS_TO_INSTALL"
  IFS=' ' read -ra EXTENSIONS <<< "$EXTENSIONS_TO_INSTALL"

  FORCE_FLAG=""
  if [ "${INSTALL_EXTENSIONS_FORCE:-}" = "true" ] || [ "${INSTALL_EXTENSIONS_FORCE:-}" = "True" ]; then
    FORCE_FLAG="--force"
    echo "Force flag enabled for extension installations"
  fi

  for ext in "${EXTENSIONS[@]}"; do
    if [ -n "$ext" ]; then
      echo "Installing extension: $ext"
      code-server --user-data-dir=/home/coder/.code/data \
                  --extensions-dir=/home/coder/.code/extensions \
                  --install-extension "$ext" $FORCE_FLAG
    fi
  done
fi
