# VS Code Environment (VSCE)

A Docker-based VS Code Environment running code-server. Get a consistent, portable VS Code experience with customizable extensions and system packages.

[![Docker Image Version](https://img.shields.io/github/v/tag/nchekwa/vsce?color=blue&label=version&style=flat-square)](https://github.com/nchekwa/vsce/tags)
[![Docker Build](https://img.shields.io/github/actions/workflow/status/nchekwa/vsce/docker-build-push.yml?branch=main&style=flat-square)](https://github.com/nchekwa/vsce/actions/workflows/docker-build-push.yml)
[![Security Scan](https://img.shields.io/github/actions/workflow/status/nchekwa/vsce/security-scan.yml?branch=main&style=flat-square)](https://github.com/nchekwa/vsce/security)

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
- **Multi-Language Support**: Pre-configured Node.js and Python environments
- **Persistent Configuration**: Settings, extensions, and data persist across restarts
- **Security Scanning**: Automated vulnerability scanning with Trivy and Snyk

## Configuration

### Docker Compose Example

```yaml
services:
  vsce:
    image: ghcr.io/nchekwa/vsce:latest
    ports:
      - "8080:8080"
    volumes:
      - ./config:/home/coder/.config
      - ./project:/home/coder/project
    environment:
      - PASSWORD="vsce"
      - INSTALL_EXTENSIONS="ms-python.python ms-vscode.vscode-yaml"
      - INSTALL_DPKG="git curl wget jq"
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PASSWORD` | VS Code password | `vsce` |
| `INSTALL_EXTENSIONS` | Space-separated VS Code extensions | `""` |
| `INSTALL_DPKG` | Space-separated system packages | `""` |
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
