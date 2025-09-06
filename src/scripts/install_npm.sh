#!/bin/bash
# Install npm and npx using NVM
set -e

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] || (
    sudo mkdir -p "$NVM_DIR"
    sudo chown $USER:$USER "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
)

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

nvm install --lts --latest-npm --default
LTS_VERSION=$(nvm version lts/*)
nvm alias default $LTS_VERSION
export PATH="$NVM_DIR/versions/node/$(nvm version default)/bin:$PATH"

# Ensure npm and npx are available
npm install -g npm@latest --force
npm install -g npx@latest --force
