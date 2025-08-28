#!/bin/bash

# NVM installer script
# Usage: ./nvm.sh [version]
# If version is not provided, the latest version will be installed

set -e

# Prevent install if npm is already available
if command -v npm >/dev/null 2>&1; then
    if npm --version >/dev/null 2>&1; then
        echo "npm is already installed (version: $(npm --version)). Skipping NVM installation."
        exit 0
    fi
fi

# Default version if we can't fetch the latest
DEFAULT_VERSION="v0.40.3"

# Process version argument
if [ -z "$1" ]; then
    # No version specified, get the latest
    echo "Fetching latest NVM version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Could not determine latest NVM version. Using fallback version $DEFAULT_VERSION."
        VERSION=$DEFAULT_VERSION
    else
        echo "Latest NVM version: $LATEST_VERSION"
        VERSION=$LATEST_VERSION
    fi
    
    echo "Installing latest NVM version: $VERSION"
else
    # Use the specified version
    if [[ "$1" == v* ]]; then
        VERSION="$1"
    else
        VERSION="v$1"
    fi
    echo "Installing specified NVM version: $VERSION"
fi

# Install NVM
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/$VERSION/install.sh"
echo "Downloading NVM from: $NVM_URL"
curl -o- "$NVM_URL" | bash

# Verify installation
if [ $? -eq 0 ]; then
    echo "NVM installation completed successfully."

    # Auto-load NVM into the current process
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # Confirm availability
    if command -v nvm >/dev/null 2>&1; then
        echo "NVM loaded. Version: $(nvm --version)"
    else
        echo "Warning: NVM not found in current process after sourcing."
    fi

    # If the script is executed (not sourced), open an interactive shell with NVM available
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        echo "Opening a new interactive shell with NVM available (type 'exit' to return)."
        exec bash -i
    fi
else
    echo "Error: NVM installation failed."
    exit 1
fi


bash -c nvm install --lts
bash -c nvm use --lts
bash -c npm --version
