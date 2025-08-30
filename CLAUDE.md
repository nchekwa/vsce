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

# View logs for specific service
docker-compose logs -f vsce
```

### Accessing the Environment

- The code-server runs on port 20080 with password authentication
- Default password: `vsce` (configurable via environment variable)
- HTTP access: <http://localhost:20080>
- HTTPS access (via Caddy): <https://localhost:20443> (when CADDY_ENABLED=true)
- SSH access: `ssh coder@localhost -p 20022` (when SSHD_ENABLED=true)

### Container Management

```bash
# Enter the running container
docker exec -it vsce bash

# View container status
docker ps | grep vsce

# View health check status
docker inspect vsce --format='{{.State.Health.Status}}'

# Remove the container
docker stop vsce && docker rm vsce
```

### Development Commands

```bash
# Access the code-server logs specifically
docker-compose logs -f vsce | grep code-server

# Access supervisor service status within container
docker exec -it vsce supervisorctl status

# Restart specific service within container
docker exec -it vsce supervisorctl restart code-server

# View supervisor logs
docker exec -it vsce supervisorctl tail code-server
```

## Architecture

### Core Components

**Dockerfile**: Base image configuration

- Uses `codercom/code-server:latest` as the base
- Installs essential utilities (jq, wget, curl, nano, supervisor, caddy, openssh-server)
- Enables default bash aliases (ll, la, l)
- Copies supervisor configuration files and modular init scripts
- Uses supervisord as the main process manager instead of a single entrypoint script
- Exposes multiple ports: 20022 (SSH), 20080 (HTTP), 20443 (HTTPS)

**src/init/init.sh**: Main container initialization orchestrator

- Runs modular installation parts in sequence during container startup
- Exports shared functions for config file parsing
- Coordinates the execution of all setup components
- Provides a clean, modular approach to container initialization

**src/init/parts/**: Modular initialization components

- `00_dirs.sh`: Creates required directories for persistent storage
- `01_info.sh`: Displays system information
- `02_dpkg.sh`: Installs system packages from environment variables or config files
- `03_extensions.sh`: Manages VS Code extensions installation with multi-line support
- `04_npm.sh`: Handles global npm package installation
- `05_ngrok.sh`: Configures ngrok tunneling if enabled
- `06_boot.sh`: Executes custom boot scripts

**src/supervisor/conf.d/**: Service configuration files

- `code-server.conf`: Manages code-server service
- `sshd.conf`: Manages SSH daemon service
- `caddy.conf`: Manages Caddy reverse proxy service
- `ngrok.conf`: Manages ngrok tunneling service
- `init.conf`: Manages the initialization process

**docker-compose.yaml**: Container orchestration

- Maps host directories for persistent storage:
  - `./project/` → `/home/coder/project` (development work)
  - `./data/config/` → `/home/coder/.config` (config files)
  - `./data/code/` → `/home/coder/.code` (VS Code data and extensions)
  - `./data/local/` → `/home/coder/.local` (user local files)
- Configures environment variables for all services
- Exposes ports: 20080 (HTTP to code-server), 20443 (HTTPS via Caddy), 20022 (SSH)
- Includes health check for service monitoring
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
- `CADDY_ENABLED`: Enable Caddy reverse proxy (default: false)
- `SSHD_ENABLED`: Enable SSH daemon service (default: true)
- `NGROK_AUTHTOKEN`: Ngrok authentication token for tunneling
- `DOCKER_USER`: Host username for user mapping

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

1. **Supervisor-Based Process Management**: Uses supervisord to manage multiple services (code-server, sshd, caddy, ngrok) instead of a single entrypoint script
2. **Modular Initialization**: System setup is broken into modular parts that execute in sequence during container startup
3. **Multi-Service Architecture**: Container runs multiple services simultaneously - code-server, SSH daemon, Caddy reverse proxy, and ngrok tunneling
4. **Configuration Flexibility**: Supports both environment variables and configuration files for different use cases
5. **Persistent Storage**: Uses mounted volumes for config, extensions, project data, and local user files
6. **Multi-language Support**: Includes both Node.js (NVM) and Python (pyenv) version management
7. **Security**: Uses password authentication by default with configurable options
8. **Directory Management**: Automatic creation of required directories for seamless persistent storage
9. **Multi-line Configuration**: YAML-style multi-line support for all package configuration types
10. **Unified Package Management**: Consistent parsing and installation logic across extensions, system packages, and npm packages

## Development Workflow

The project is designed for containerized development where:

- All development tools and configurations are containerized
- Projects are mounted from the host system in `project/`
- Extensions and settings persist across container restarts via `data/code/` and `data/config/`
- Multiple language runtimes can be managed within the same environment
- Supervisor manages multiple services for robust process management

### Directory Structure

- `project/` - Development work directory (mounted as `/home/coder/project`)
- `data/config/` - Persistent configuration files (mounted as `/home/coder/.config`)
- `data/code/` - VS Code data and extensions (mounted as `/home/coder/.code`)
- `data/local/` - User local files (mounted as `/home/coder/.local`)
- `src/init/` - Modular initialization scripts
- `src/supervisor/conf.d/` - Supervisor service configurations
- `src/scripts/` - Installation scripts (Python setup, etc.)

### Service Management

All services are managed by supervisord:
- **code-server**: VS Code in browser (port 20080)
- **sshd**: SSH daemon service (port 20022)
- **caddy**: Reverse proxy for HTTPS (port 20443, when enabled)
- **ngrok**: Tunneling service (when enabled)
- **init**: Container initialization process

The initialization process runs only once at container startup, then exits gracefully, leaving the services running under supervisor.

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

### Modular Initialization System

**parse_config_file Function**: Shared library function exported from init.sh

- Located in `src/init/init.sh:8-26`
- Parses configuration files and filters out comments and empty lines
- Handles comment lines starting with `#` and empty lines
- Returns space-separated valid entries for processing
- Used by all modular parts for consistent config file parsing

**Modular Parts Execution**: Sequential processing in src/init/init.sh

- Executes parts in numeric order (`00_dirs.sh`, `01_info.sh`, etc.)
- Each part runs as a separate bash script with error handling
- Provides clean separation of concerns for initialization tasks
- Enables easy addition of new initialization components
