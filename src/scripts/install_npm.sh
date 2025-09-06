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

nvm install --lts
LTS_VERSION=$(nvm version lts/*)
nvm alias default $LTS_VERSION
nvm use default
