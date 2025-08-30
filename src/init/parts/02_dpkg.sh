#!/bin/bash
# Install system packages from env var INSTALL_DPKG and/or /home/coder/.config/dpkg.txt
set -euo pipefail


PACKAGES_TO_INSTALL=""

# Add ngrok repository if not already present
if [ ! -f /etc/apt/sources.list.d/ngrok.list ]; then
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
fi


if [ -n "${INSTALL_DPKG:-}" ]; then
  echo "Found packages in environment variable:${INSTALL_DPKG//$'\n'/ }"
  CLEANED_PACKAGES="${INSTALL_DPKG//\"/}"
  CLEANED_PACKAGES="${CLEANED_PACKAGES//,/ }"
  PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $CLEANED_PACKAGES"
fi

DPKG_CONFIG_FILE="/home/coder/.config/dpkg.txt"
if [ -f "$DPKG_CONFIG_FILE" ]; then
  CONFIG_PACKAGES=$(parse_config_file "$DPKG_CONFIG_FILE")
  PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $CONFIG_PACKAGES"
fi

if [ -n "$PACKAGES_TO_INSTALL" ]; then
  echo "Installing system packages:${PACKAGES_TO_INSTALL//$'\n'/ }"
  sudo apt-get update
  # shellcheck disable=SC2086
  sudo apt-get install -y $PACKAGES_TO_INSTALL
fi



if [ -n "$NGROK_AUTHTOKEN" ]; then
  echo "Installing ngrok"
  sudo apt-get install -y ngrok
fi