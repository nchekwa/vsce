# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based VS Code Environment (vsce) that provides a containerized development environment running code-server. The project enables developers to have a consistent, portable VS Code experience in a Docker container with customizable extensions and system packages.

## Common Development Commands

### Building and Running

```bash
# Build the Docker image
docker build -t vsce:1.0 .

# Start the container
docker-compose up -d

# Stop the container
docker-compose down

# View container logs
docker-compose logs -f
```

### Accessing the Environment

- The code-server runs on port 8080 with password authentication
- Default password: `vsce` (configurable via environment variable)
- Access at: <http://localhost:8080>

### Container Management

```bash
# Enter the running container
docker exec -it vsce bash

# View container status
docker ps | grep vsce

# Remove the container
docker stop vsce && docker rm vsce
```

## Architecture

### Core Components

**Dockerfile**: Base image configuration

- Uses `codercom/code-server:latest` as the base
- Installs essential utilities (jq, wget, curl, nano)
- Enables default bash aliases (ll, la, l)
- Copies installation scripts and sets custom entrypoint

**entrypoint.sh**: Main container initialization script

- Manages VS Code extensions installation from environment variables or config files
- Handles system package installation via apt
- Installs global npm packages from environment variables or config files
- Configures authentication and starts code-server
- Supports custom boot scripts for additional setup
- Uses dedicated user-data and extensions directories for persistence
- Automatically creates required directories for persistent storage
- Handles multi-line configuration parsing for all package types

**docker-compose.yaml**: Container orchestration

- Maps host config directory to `/home/coder/.config`
- Maps host project directory to `/home/coder/project`
- Configures environment variables for customization
- Exposes port 8080 for code-server access
- Demonstrates multi-line YAML configuration for all package types

### Configuration System

The container supports flexible configuration through multiple methods:

**Environment Variables:**

- `INSTALL_EXTENSIONS`: List of VS Code extensions (supports multi-line YAML format)
- `INSTALL_EXTENSIONS_FORCE`: Force extension reinstallation
- `EXTENSIONS_UPDATE`: Update all existing extensions
- `INSTALL_DPKG`: System packages to install via apt (supports multi-line YAML format)
- `INSTALL_NPM`: Global npm packages to install (supports multi-line YAML format)
- `PASSWORD`: Authentication password for code-server
- `BOOT_INSTALL_SCRIPT`: Path to custom boot script

**Configuration Files:**

- `/home/coder/.config/extensions.txt`: List of extensions to install
- `/home/coder/.config/dpkg.txt`: List of system packages to install
- `/home/coder/.config/npm.txt`: List of npm packages to install globally
- `/home/coder/.config/boot.sh`: Custom boot script
- `/home/coder/.config/code-server/config.yaml`: code-server configuration

### Installation Scripts

**install/nvm.sh**: Node.js version management

- Installs NVM for Node.js version management
- Automatically installs latest LTS Node.js version
- Skips installation if npm is already available
- Configures shell integration

**install/python3.sh**: Python environment setup

- Installs system Python dependencies
- Sets up pyenv for Python version management
- Configures virtual environment support
- Integrates with shell profiles

### Key Implementation Details

**Multi-line Configuration Processing:**

- Extension, system package, and npm configurations support multi-line YAML format
- Uses `tr '\n' ' '` to convert newlines to spaces
- Handles quotes and comma separation with cleanup
- Removes extra spaces with sed cleanup
- Works with both environment variables and config files

**Directory Auto-creation Logic:**

- Located in entrypoint.sh lines 48-52
- Automatically creates `/home/coder/.code/data` and `/home/coder/.code/extensions` if they don't exist
- Ensures persistent storage works out of the box
- Prevents startup errors from missing directories

**NPM Package Management:**

- Environment variable: `INSTALL_NPM`
- Config file: `/home/coder/.config/npm.txt`
- Handles multi-line input similar to extensions
- Installs packages using `npm install -g`
- Automatically installs Node.js via nvm.sh if npm is not available
- Supports the same parsing logic as extensions and system packages

## Key Architecture Decisions

1. **Separation of Concerns**: The entrypoint script handles system setup, extension management, and code-server startup separately
2. **Configuration Flexibility**: Supports both environment variables and configuration files for different use cases
3. **Persistent Storage**: Uses mounted volumes for config, extensions, and project data
4. **Multi-language Support**: Includes both Node.js (NVM) and Python (pyenv) version management
5. **Security**: Uses password authentication by default with configurable options
6. **Directory Management**: Automatic creation of required directories for seamless persistent storage
7. **Multi-line Configuration**: YAML-style multi-line support for all package configuration types
8. **Unified Package Management**: Consistent parsing and installation logic across extensions, system packages, and npm packages

## Development Workflow

The project is designed for containerized development where:

- All development tools and configurations are containerized
- Projects are mounted from the host system
- Extensions and settings persist across container restarts
- Multiple language runtimes can be managed within the same environment
- Always call @agent-documentation-writer for update documentation

The `project/` directory is intended for mounting actual development work, while the `config/` directory maintains persistent settings and configurations across container lifecycle.

## Configuration Implementation Details

### Multi-line Environment Variable Processing

All package installation environment variables support multi-line YAML format:

```bash
# Implementation logic from entrypoint.sh
CLEANED_EXTENSIONS=$(echo "${INSTALL_EXTENSIONS}" | tr '\n' ' ')
CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//\"/}"
CLEANED_EXTENSIONS="${CLEANED_EXTENSIONS//,/ }"
CLEANED_EXTENSIONS=$(echo "${CLEANED_EXTENSIONS}" | sed -e 's/[[:space:]]\+/ /g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
```

This processing:
1. Converts newlines to spaces using `tr '\n' ' '`
2. Removes quotes to handle YAML string formatting
3. Replaces commas with spaces for flexibility
4. Cleans up extra spaces that may result from newlines

### Directory Auto-creation Logic

```bash
# From entrypoint.sh lines 48-52
if [ ! -d "/home/coder/.code/data" ] || [ ! -d "/home/coder/.code/extensions" ]; then
    echo "Creating user-data-dir and extensions-dir"
    mkdir -p /home/coder/.code/data
    mkdir -p /home/coder/.code/extensions
fi
```

This ensures:
- Persistent storage directories exist before code-server starts
- No startup errors from missing directories
- Seamless operation across container restarts
- User data and extensions are properly persisted

### NPM Package Management Implementation

```bash
# NPM installation logic from entrypoint.sh
if [ ! -z "${INSTALL_NPM}" ]; then
    echo "Found npm packages in environment variable: ${INSTALL_NPM}"
    
    # Remove quotes and replace commas with spaces
    CLEANED_NPM_PACKAGES="${INSTALL_NPM//\"/}"
    CLEANED_NPM_PACKAGES="${CLEANED_NPM_PACKAGES//,/ }"
    
    NPM_PACKAGES_TO_INSTALL="$NPM_PACKAGES_TO_INSTALL $CLEANED_NPM_PACKAGES"
fi

# Install npm packages if any were specified
if [ ! -z "$NPM_PACKAGES_TO_INSTALL" ]; then
    echo "Installing npm packages: $NPM_PACKAGES_TO_INSTALL"
    
    # Use nvm.sh script to install Node.js and npm
    if ! command -v npm &> /dev/null; then
        echo "npm not found, installing Node.js using nvm.sh..."
        bash /home/coder/install/nvm.sh
        
        # Load nvm in the current shell
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Install packages globally
    npm install -g $NPM_PACKAGES_TO_INSTALL
fi
```

This implementation:
1. Parses NPM packages from environment variables or config files
2. Handles multi-line input with the same logic as extensions
3. Automatically installs Node.js if not available
4. Installs packages globally using `npm install -g`
5. Integrates with the existing configuration system
