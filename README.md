# VS Code Environment (VSCE)

A Docker-based VS Code Environment running code-server. Get a consistent, portable VS Code experience with customizable extensions and system packages.

[![Docker Image Version](https://img.shields.io/github/v/tag/nchekwa/vsce?color=blue&label=version&style=flat-square)](https://github.com/nchekwa/vsce/tags)
[![Docker Build](https://img.shields.io/github/actions/workflow/status/nchekwa/vsce/docker-publish.yml?branch=main&style=flat-square)](https://github.com/nchekwa/vsce/actions/workflows/docker-publish.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![vsce](./images/ngrok-view.png)

## Quick Start

```bash
git clone https://github.com/nchekwa/vsce.git
cd vsce
docker-compose up -d
```

Or use the pre-built image directly:

```yaml
image: ghcr.io/nchekwa/vsce:latest
```

After starting the container, access VS Code at `http://localhost:20080` with the default password `vsce`.

## Features

- **VS Code in Browser**: Access a full VS Code experience through code-server.
- **Automatic Extension Management**: Extensions are pre-installed on container startup.
- **System Package Installation**: Add Debian packages to customize your environment.
- **Global NPM Package Management**: Install npm packages globally within the container.
- **Multi-Language Support**: Pre-configured environments for Node.js and Python.
- **Multi-line Configuration**: Supports YAML-style multi-line configurations in docker-compose.
- **Directory Auto-Creation**: Automatically creates directories for persistent storage.
- **Persistent Configuration**: Settings, extensions, and data remain across restarts.
- **Security Scanning**: Includes automated vulnerability scanning with Trivy and Snyk.

## Configuration

### Docker Compose Example

```yaml
services:
  vsce:
    container_name: vsce
    hostname: vsce
    image: ghcr.io/nchekwa/vsce:latest
    ports:
      - 20080:20080     # HTTP to Code-Server
      - 20443:20443     # HTTPS to Caddy->Code-Server[HTTP]
      - 20022:20022     # SSH (if env SSHD_ENABLED=true)
    volumes:
      - ./project/:/home/coder/project             # Project files -> mounted as /home/coder/project
      - ./data/config/:/home/coder/.config              # User config files
      - ./data/code/:/home/coder/.code                  # User files related to code-server
      - ./data/local/:/home/coder/.local                # User local files
      - /var/run/docker.sock:/var/run/docker.sock       # If you need to access from inside docker to host docker instance
    #user: "${UID}:${GID}"
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
        git
        docker.io
      INSTALL_NPM: |
        @anthropic-ai/claude-code
        @proofs-io/shotgun
        @proofs-io/shotgun-server
      CADDY_ENABLED: "${CADDY_ENABLED:-false}"
      SSHD_ENABLED: "${SSHD_ENABLED:-false}"
      NGROK_AUTHTOKEN: "${NGROK_AUTHTOKEN:-}"
    stdin_open: true
```

> **Warning**: Some extensions like KiloCode, Roo Code, and Cline may not work with VSCE unless accessed over an SSL proxy with a valid certificate. This is due to Chrome blocking web views.
>
> If using Chrome, you can bypass this by marking web views as secure:
>
> 1. Open Chrome and navigate to:
>
>    ```
>    chrome://flags/#unsafely-treat-insecure-origin-as-secure
>    ```
>
> 2. Add your VSCE URL to the list of insecure origins, e.g., `http://192.168.1.100:20080`.
>
> **Note**: This workaround applies only to HTTP connections. For HTTPS/SSL connections, ensure you use a valid certificate. Use ngrok for testing SSL; check the `project` folder for a **vsce_ngrok.txt** file with the URL.

![unsafely-treat-insecure-origin-as-secure](./images/chrome-unsecure-http.png)

### Environment Variables

| Variable                   | Description                              | Default   |
|----------------------------|------------------------------------------|-----------|
| `PASSWORD`                | VS Code access password                 | `vsce`    |
| `INSTALL_EXTENSIONS`      | VS Code extensions (supports multi-line YAML) | `""`     |
| `INSTALL_DPKG`            | System packages to install via apt      | `""`     |
| `INSTALL_NPM`             | Global npm packages to install          | `""`     |
| `EXTENSIONS_UPDATE`       | Update existing extensions              | `false`   |
| `INSTALL_EXTENSIONS_FORCE`| Force reinstall extensions              | `false`   |
| `BOOT_INSTALL_SCRIPT`     | Path to custom boot script              | `""`     |
| `CADDY_ENABLED`          | Enable Caddy reverse proxy              | `false`   |
| `SSHD_ENABLED`            | Enable SSH server                       | `false`   |
| `NGROK_AUTHTOKEN`         | Ngrok authentication token              | `""`     |

## Installing Extras in Docker

VSCE supports automatic installation of additional components during container startup. This section explains how to install extras across different categories and configuration methods.

### Autoinstall Categories

#### VSCE Extensions

VSCE lets you pre-install VS Code extensions, ready to use when the container starts.

- **Via Configuration File**: Create `/config/extensions.txt` with a list of extension IDs.

  ```
  ms-python.python
  redhat.vscode-yaml
  ms-azuretools.vscode-docker
  ```

- **Via Docker-Compose**: Use the `INSTALL_EXTENSIONS` environment variable in your `docker-compose.yaml`.

  ```yaml
  environment:
    INSTALL_EXTENSIONS: |
      ms-python.python
      redhat.vscode-yaml
      ms-azuretools.vscode-docker
  ```

- **Via Environment Variable**: Set `INSTALL_EXTENSIONS` when running the Docker command.

  ```bash
  docker run -e INSTALL_EXTENSIONS="ms-python.python redhat.vscode-yaml" ghcr.io/nchekwa/vsce:latest
  ```

#### Debian Packages

Install additional system packages via `apt` to tailor your environment.

- **Via Configuration File**: Create `/config/dpkg.txt` with a list of packages.

  ```
  git
  curl
  wget
  ```

- **Via Docker-Compose**: Use the `INSTALL_DPKG` environment variable in your `docker-compose.yaml`.

  ```yaml
  environment:
    INSTALL_DPKG: |
      git
      curl
      wget
  ```

- **Via Environment Variable**: Set `INSTALL_DPKG` when running the Docker command.

  ```bash
  docker run -e INSTALL_DPKG="git curl" ghcr.io/nchekwa/vsce:latest
  ```

#### NPM Packages

Install global npm packages to enhance development workflows.

- **Via Configuration File**: Create `/config/npm.txt` with a list of packages.

  ```
  typescript
  nodemon
  eslint
  ```

- **Via Docker-Compose**: Use the `INSTALL_NPM` environment variable in your `docker-compose.yaml`.

  ```yaml
  environment:
    INSTALL_NPM: |
      typescript
      nodemon
      eslint
  ```

- **Via Environment Variable**: Set `INSTALL_NPM` when running the Docker command.

  ```bash
  docker run -e INSTALL_NPM="typescript nodemon" ghcr.io/nchekwa/vsce:latest
  ```

### Notes on Configuration

- Multi-line YAML format is supported for improved readability in `docker-compose.yaml` files.
- When npm packages are specified, VSCE checks for npm availability and installs Node.js using `nvm.sh` if needed.

#### Custom Boot Script

As the final step during container initialization, VSCE checks for a custom `boot.sh` script to run. This script executes after all other installation steps. By default, it looks for the script at `/home/coder/.config/boot.sh`, but you can specify a different path using the `BOOT_INSTALL_SCRIPT` environment variable. **Note**: The path in `BOOT_INSTALL_SCRIPT` is internal to the Docker container. If your script is external, it must be mapped to an internal path using a volume.

- **Via Configuration File**: Place your custom script at `/home/coder/.config/boot.sh` (or another location if specified) with your commands. If the script is external, ensure it is mapped via a volume.

  ```bash
  #!/bin/bash
  echo "Custom setup commands here..."
  # Add your custom actions here
  ```

- **Via Environment Variable**: Set `BOOT_INSTALL_SCRIPT` to point to your custom script path (internal to Docker) when running the Docker command. Ensure the script is accessible inside the container.

  ```bash
  docker run -e BOOT_INSTALL_SCRIPT="/home/coder/.config/custom_boot.sh" -v "/path/on/host:/home/coder/.config" ghcr.io/nchekwa/vsce:latest
  ```

- **Via Docker-Compose**: Use the `BOOT_INSTALL_SCRIPT` environment variable in your `docker-compose.yaml` to specify the path to your custom script (internal to Docker). Map the script via a volume if it is external.

  ```yaml
  environment:
    BOOT_INSTALL_SCRIPT: "/home/coder/.config/custom_boot.sh"
  volumes:
    - ./config:/home/coder/.config
  ```

## Directory Auto-Creation

VSCE automatically creates necessary directories for persistent storage:

- `/home/coder/.code/data` - Stores user data and settings.
- `/home/coder/.code/extensions` - Stores VS Code extensions.

This ensures:

- Extensions persist across container restarts.
- User settings are retained.
- No startup errors due to missing directories.
- A seamless persistent storage experience.

## Base Code-Server vs. OpenVSCode-Server

Two projects emulate Visual Studio Code in the browser:

- [OpenVSCode-Server](https://github.com/gitpod-io/openvscode-server/)
- [code-server](https://github.com/coder/code-server)

### What's the Difference?

Both code-server and OpenVSCode-Server enable browser-based VS Code access, but they differ in integration approach:

- **OpenVSCode-Server**: A direct fork of VS Code with changes committed directly.
- **code-server**: Uses VS Code as a submodule with changes applied via patch files.

## CI/CD

Automated workflows manage:

- **Version Management**: Semantic versioning based on commit messages.
- **Multi-Platform Builds**: Support for Linux AMD64 and ARM64.
- **Security Scanning**: Integration with Trivy, Snyk, and Dockle.
- **Docker Publishing**: Automatic image publishing to GitHub Container Registry.

See [GitHub Actions](https://github.com/nchekwa/vsce/actions) for details.

## License

MIT License - see [LICENSE](LICENSE) file.
