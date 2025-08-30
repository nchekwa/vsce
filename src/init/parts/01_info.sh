#!/bin/bash
# Print code-server version and list currently installed extensions
set -euo pipefail

version_info=$(code-server --version)
echo "Current version: $(echo "$version_info" | tr '\n' ' ')"

echo "Existing installed extensions:"
code-server \
  --user-data-dir=/home/coder/.code/data \
  --extensions-dir=/home/coder/.code/extensions \
  --list-extensions --show-versions
