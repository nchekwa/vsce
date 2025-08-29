# VS Code Environment (VSCE)

A Docker-based VS Code Environment running code-server. Get a consistent, portable VS Code experience with customizable extensions and system packages.

[![Docker Image Version](https://img.shields.io/github/v/tag/nchekwa/vsce?color=blue&label=version&style=flat-square)](https://github.com/nchekwa/vsce/tags)
[![Docker Build](https://img.shields.io/github/actions/workflow/status/nchekwa/vsce/docker-publish.yml?branch=main&style=flat-square)](https://github.com/nchekwa/vsce/actions/workflows/docker-publish.yml)
[![Security Scan](https://img.shields.io/github/actions/workflow/status/nchekwa/vsce/security-scan.yml?branch=main&style=flat-square)](https://github.com/nchekwa/vsce/actions/workflows/security-scan.yml)

## Quick Start

```bash
git clone https://github.com/nchekwa/vsce.git
cd vsce
docker-compose up -d
```

Access VS Code at `http://localhost:8080` with password `vsce`.

## Features

- **VS Code in Browser**: Full VS Code experience via code-server
- **Automatic Extension Management**: Pre-installed extensions on container start
- **System Package Installation**: Install additional Debian packages
- **Global NPM Package Management**: Install npm packages globally across the container
- **Multi-Language Support**: Pre-configured Node.js and Python environments
- **Multi-line Configuration**: Support for YAML-style multi-line configuration in docker-compose
- **Directory Auto-Creation**: Automatic creation of required directories for persistent storage
- **Persistent Configuration**: Settings, extensions, and data persist across restarts
- **Security Scanning**: Automated vulnerability scanning with Trivy and Snyk

## Configuration

### Docker Compose Example

```yaml
services:
  vsce:
    container_name: vsce
    hostname: vsce
    image: ghcr.io/nchekwa/vsce:latest
    ports:
      - 8080:8080
    volumes:
      - ./config/:/home/coder/.config
      - ./project/:/home/coder/project
    user: "${UID}:${GID}"
    environment:
      DOCKER_USER: $USER
      PASSWORD: ${PASSWORD:-vsce}
      INSTALL_EXTENSIONS_FORCE: ${INSTALL_EXTENSIONS_FORCE:-false}
      INSTALL_EXTENSIONS: |
        ms-python.python
        ms-python.flake8
        ms-python.pylint
        ms-pyright.pyright
        redhat.vscode-yaml
        ms-azuretools.vscode-docker
        ms-azuretools.vscode-containers
        kilocode.kilo-code
        anthropic.claude-code
      INSTALL_DPKG: |
        curl
        git
        jq
        docker.io
      INSTALL_NPM: |
        @anthropic-ai/claude-codeafte
        @proofs-io/shotgun
        @proofs-io/shotgun-server
    stdin_open: true
```

*Please note that [KiloCode #2191](https://github.com/Kilo-Org/kilocode/issues/2103) / Roo Code / Cline - will not work with VSCE*.

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PASSWORD` | VS Code password | `vsce` |
| `INSTALL_EXTENSIONS` | VS Code extensions (supports multi-line YAML) | `""` |
| `INSTALL_DPKG` | System packages to install via apt | `""` |
| `INSTALL_NPM` | Global npm packages to install | `""` |
| `EXTENSIONS_UPDATE` | Update existing extensions | `false` |
| `INSTALL_EXTENSIONS_FORCE` | Force reinstall extensions | `false` |
| `BOOT_INSTALL_SCRIPT` | Custom boot script path | `""` |

### Configuration Files

Create `/config/extensions.txt`:

```
ms-python.python
ms-vscode.vscode-yaml
redhat.vscode-yaml
```

Create `/config/dpkg.txt`:

```
git
curl
wget
jq
htop
```

Create `/config/npm.txt`:

```
@anthropic-ai/claude-code
typescript
nodemon
eslint
prettier
```

## Multi-line Configuration Support

The environment variables support multi-line YAML format for better readability in docker-compose files:

### Multi-line Extensions

```yaml
environment:
  INSTALL_EXTENSIONS: |
    ms-python.flake8
    ms-python.pylint
    redhat.vscode-yaml
    ms-python.python
    ms-azuretools.vscode-docker
    kilocode.kilo-code
```

### Multi-line System Packages

```yaml
environment:
  INSTALL_DPKG: |
    curl
    git
    jq
    htop
    tree
```

### Multi-line NPM Packages

```yaml
environment:
  INSTALL_NPM: |
    @anthropic-ai/claude-code
    typescript
    nodemon
    eslint
    prettier
```

## Global NPM Package Management

VSCE supports automatic installation of global npm packages during container startup:

### Using Environment Variables

```bash
# Set via docker-compose
environment:
  INSTALL_NPM: "typescript nodemon eslint prettier"

# Or set via command line
docker run -e INSTALL_NPM="typescript nodemon" ghcr.io/nchekwa/vsce:latest
```

### Using Configuration Files

Create `/config/npm.txt`:

```
# Global npm packages to install
@anthropic-ai/claude-code
typescript
nodemon
eslint
prettier
@vue/cli
create-react-app
```

### Automatic Node.js Setup

When npm packages are specified, VSCE automatically:

1. Checks if npm is available
2. If not available, installs Node.js using nvm.sh
3. Installs the specified packages globally

## Directory Auto-Creation

VSCE automatically creates required directories for persistent storage:

- `/home/coder/.code/data` - User data and settings
- `/home/coder/.code/extensions` - VS Code extensions

This ensures that:

- Extensions persist across container restarts
- User settings are maintained
- No startup errors from missing directories
- Seamless persistent storage experience

## Custom Scripts

Create `/config/boot.sh` for custom initialization:

```bash
#!/bin/bash
echo "Custom setup commands here..."
```

## CI/CD

Automated workflows handle:

- **Version Management**: Automatic semantic versioning based on commit messages
- **Multi-Platform Builds**: Linux AMD64 and ARM64 support
- **Security Scanning**: Trivy, Snyk, and Dockle integration
- **Docker Publishing**: Automated image publishing to GitHub Container Registry

See [GitHub Actions](https://github.com/nchekwa/vsce/actions) for details.

## License

MIT License - see [LICENSE](LICENSE) file.
