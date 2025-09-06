#!/bin/bash

# Download the installer script:
curl -fsSL https://get.pulumi.com | bash
# curl -fsSL https://get.pulumi.com | sh -s -- --version <version>
# curl -fsSL https://get.pulumi.com | sh -s -- --version dev

# Add Pulumi to your PATH:
echo 'export PATH=$PATH:/home/coder/.pulumi/bin' >> ~/.bashrc

# Reload your shell configuration:
sourcing ~/.bashrc

# Verify the installation:
pulumi version