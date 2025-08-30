#!/bin/bash
# Install npm packages from env var INSTALL_NPM and/or /home/coder/.config/npm.txt
set -euo pipefail


ENV_NPM_PACKAGES=""
FILE_NPM_PACKAGES=""
NPM_PACKAGES_TO_INSTALL=""

# Process environment variable packages
if [ -n "${INSTALL_NPM:-}" ]; then
  ENV_NPM_PACKAGES="${INSTALL_NPM//\"/}"
  ENV_NPM_PACKAGES="${ENV_NPM_PACKAGES//,/ }"
  NPM_PACKAGES_TO_INSTALL="$NPM_PACKAGES_TO_INSTALL $ENV_NPM_PACKAGES"
fi

# Process config file packages
NPM_CONFIG_FILE="/home/coder/.config/npm.txt"
if [ -f "$NPM_CONFIG_FILE" ]; then
  FILE_NPM_PACKAGES=$(parse_config_file "$NPM_CONFIG_FILE")
  NPM_PACKAGES_TO_INSTALL="$NPM_PACKAGES_TO_INSTALL $FILE_NPM_PACKAGES"
fi

# Print combined list of packages
if [ -n "$NPM_PACKAGES_TO_INSTALL" ]; then
  echo -s "Found npm packages:\n$(echo "$NPM_PACKAGES_TO_INSTALL" | tr -s ' ')"
fi

if [ -n "$NPM_PACKAGES_TO_INSTALL" ]; then
  # Normalize for execution
  NPM_PACKAGES_TO_INSTALL=$(printf "%s" "$NPM_PACKAGES_TO_INSTALL" | tr ',\n\r\t' '    ' | xargs)
  echo "Installing npm packages: $NPM_PACKAGES_TO_INSTALL"
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found, installing Node.js using NVM..."
    # Inline NVM installer (adapted)
    DEFAULT_VERSION="v0.40.3"
    VERSION=""
    echo "Fetching latest NVM version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') || true
    if [ -z "$LATEST_VERSION" ]; then
      echo "Could not determine latest NVM version. Using fallback version $DEFAULT_VERSION."
      VERSION=$DEFAULT_VERSION
    else
      echo "Latest NVM version: $LATEST_VERSION"
      VERSION=$LATEST_VERSION
    fi
    NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/$VERSION/install.sh"
    echo "Downloading NVM from: $NVM_URL"
    curl -s -o- "$NVM_URL" | bash
    # Source NVM from standard locations (XDG-first), pick the first that exists
    # Temporarily disable nounset because nvm.sh references unset vars (e.g., PROVIDED_VERSION)
    set +u
    for candidate in "$HOME/.config/nvm" "$HOME/.nvm"; do
      if [ -s "$candidate/nvm.sh" ]; then
        export NVM_DIR="$candidate"
        . "$candidate/nvm.sh"
        [ -s "$candidate/bash_completion" ] && . "$candidate/bash_completion"
        break
      fi
    done
    if command -v nvm >/dev/null 2>&1; then
      echo "NVM loaded. Version: $(nvm --version)"
      echo "Installing and activating latest LTS Node.js via nvm..."
      nvm install --lts
      nvm use --lts
      echo "npm version after NVM install: $(npm --version)"
      set -u
    else
      set -u
      echo "Warning: NVM still not available after install. Skipping npm installs."
      exit 0
    fi
  fi
  # Upgrade npm to latest version
  echo "Upgrading npm to latest version..."
  npm install -g npm@latest || echo "warn: failed to upgrade npm (continuing)" >&2
  # Perform installs at the very end, per-package to avoid total failure on one error
  for pkg in $NPM_PACKAGES_TO_INSTALL; do
    if npm list -g "$pkg" >/dev/null 2>&1; then
      echo "$pkg is already installed, skipping..."
    else
      echo "npm install -g $pkg"
      if ! npm install -g "$pkg"; then
        echo "warn: failed to install $pkg (continuing)" >&2
      fi
    fi
  done
  
fi
