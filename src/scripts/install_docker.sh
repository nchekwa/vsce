install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

OS_ID=$(grep '^ID=' /etc/os-release | cut -d '=' -f2)
VERSION_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d '=' -f2)
echo "Detected OS: $OS_ID"
echo "Version Codename: $VERSION_CODENAME"

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS_ID $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/sbin/docker-compose