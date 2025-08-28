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

**docker-compose.yaml**: Container orchestration

- Maps host config directory to `/home/coder/.config`
- Maps host project directory to `/home/coder/project`
- Configures environment variables for customization
- Exposes port 8080 for code-server access

### Configuration System

The container supports flexible configuration through multiple methods:

**Environment Variables:**

- `INSTALL_EXTENSIONS`: Space-separated list of VS Code extensions
- `INSTALL_EXTENSIONS_FORCE`: Force extension reinstallation
- `EXTENSIONS_UPDATE`: Update all existing extensions
- `INSTALL_DPKG`: System packages to install via apt
- `INSTALL_NPM`: Global npm packages to install
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

## Key Architecture Decisions

1. **Separation of Concerns**: The entrypoint script handles system setup, extension management, and code-server startup separately
2. **Configuration Flexibility**: Supports both environment variables and configuration files for different use cases
3. **Persistent Storage**: Uses mounted volumes for config, extensions, and project data
4. **Multi-language Support**: Includes both Node.js (NVM) and Python (pyenv) version management
5. **Security**: Uses password authentication by default with configurable options

## Development Workflow

The project is designed for containerized development where:

- All development tools and configurations are containerized
- Projects are mounted from the host system
- Extensions and settings persist across container restarts
- Multiple language runtimes can be managed within the same environment

The `project/` directory is intended for mounting actual development work, while the `config/` directory maintains persistent settings and configurations across container lifecycle.
