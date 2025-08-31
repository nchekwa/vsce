# Dockerfile arguments
FROM codercom/code-server:latest

# Re-declare build arg after FROM to make it available to this stage
ARG VERSION="0.6.0"

# Labels
LABEL version="0.6.0"
LABEL maintainer="vsce"
LABEL description="Docker-based VS Code Environment with code-server"
LABEL org.opencontainers.image.title="VS Code Environment (VSCE)"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/nchekwa/vsce"
ENV SSHD_ENABLED=true \
    SSHD_PORT=22 \
    TZ=Etc/UTC

USER root

RUN sed -i '/^#alias ll=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias la=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias l=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias ll=/s/^#//' /root/.bashrc && \
    sed -i '/^#alias la=/s/^#//' /root/.bashrc && \
    sed -i '/^#alias l=/s/^#//' /root/.bashrc  && \
    apt-get update && \
    apt-get install -y jq wget curl nano iputils-ping net-tools dnsutils traceroute supervisor openssh-server caddy && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^logfile=/user=root\nlogfile=/' /etc/supervisor/supervisord.conf && \
    sed -i 's/^chmod=0700/chmod=0777/' /etc/supervisor/supervisord.conf && \
    sed -i 's/run\//run\/supervisor\//g' /etc/supervisor/supervisord.conf  && \
    mkdir -p /init/ && \
    chown -R coder:users /init/ && \
    mkdir -p /var/log/supervisor/ && \
    chown -R root:root /var/log/supervisor/ && \
    mkdir -p /var/run/supervisor/ && \
    chown -R root:root /var/run/supervisor/

COPY ./src/supervisor/conf.d/* /etc/supervisor/conf.d/
COPY ./src/caddy/Caddyfile /etc/caddy/Caddyfile


USER coder
COPY --chown=coder:users "src/scripts/" /home/coder/scripts/
COPY --chown=coder:users "src/init/" /init/
WORKDIR /home/coder
EXPOSE 20022 20080 20443

# Use supervisord to manage both VNC and Uvicorn
ENTRYPOINT ["sudo", "-E", "/usr/bin/supervisord", "--strip_ansi", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
