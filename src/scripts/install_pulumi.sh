#!/bin/bash

# Download the installer script:
curl -fsSL https://get.pulumi.com | sh
# curl -fsSL https://get.pulumi.com | sh -s -- --version <version>
# curl -fsSL https://get.pulumi.com | sh -s -- --version dev

# Reload your shell configuration:
source ~/.bashrc

# Verify the installation:
pulumi version
