FROM codercom/code-server:latest

COPY --chown=coder:users "install/" /home/coder/install/

RUN sed -i '/^#alias ll=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias la=/s/^#//' /home/coder/.bashrc && \
    sed -i '/^#alias l=/s/^#//' /home/coder/.bashrc

RUN sudo apt-get update && \
    sudo apt-get install -y jq wget curl nano && \
    sudo rm -rf /var/lib/apt/lists/*


COPY "entrypoint.sh" /
ENTRYPOINT [ "/entrypoint.sh" ]