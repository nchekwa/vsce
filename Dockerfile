# Dockerfile arguments
ARG VERSION="0.5.0"

FROM codercom/code-server:latest

# Labels
LABEL version="0.5.2"
LABEL maintainer="vsce"
LABEL description="Docker-based VS Code Environment with code-server"
LABEL org.opencontainers.image.title="VS Code Environment (VSCE)"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/${GITHUB_REPOSITORY}"

COPY --chown=coder:users "install/" /home/coder/install/

RUN sed -i '/^#alias ll=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias la=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias l=/s/^#//' /home/coder/.bashrc

RUN sudo apt-get update && \
    sudo apt-get install -y jq wget curl nano && \
    sudo rm -rf /var/lib/apt/lists/*


COPY "entrypoint.sh" /
ENTRYPOINT [ "/entrypoint.sh" ]