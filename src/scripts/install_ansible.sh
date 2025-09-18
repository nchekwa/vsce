if [ -z "$1" ]; then
    # Auto-detect Debian version
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DEBIAN_VERSION=$(echo $VERSION_ID | cut -d. -f1)
        echo "Auto-detected Debian version: $DEBIAN_VERSION ($PRETTY_NAME)"
    else
        echo "Usage: $0 <debian_version>"
        echo "Example: $0 13  (for Debian 13 Trixie)"
        echo "Could not auto-detect Debian version. Please specify it manually."
        exit 1
    fi
else
    DEBIAN_VERSION=$1
fi

# Map Debian version numbers to Ubuntu codenames for PPA compatibility
case $DEBIAN_VERSION in
    13)
        UBUNTU_CODENAME="jammy"  # Debian 13 Trixie -> Ubuntu 22.04 LTS
        ;;
    12)
        UBUNTU_CODENAME="jammy"  # Debian 12 Bookworm -> Ubuntu 22.04 LTS
        ;;
    11)
        UBUNTU_CODENAME="focal"  # Debian 11 Bullseye -> Ubuntu 20.04 LTS
        ;;
    10)
        UBUNTU_CODENAME="bionic"  # Debian 10 Buster -> Ubuntu 18.04 LTS
        ;;
    *)
        echo "Unsupported Debian version: $DEBIAN_VERSION"
        echo "Supported versions: 10, 11, 12, 13"
        exit 1
        ;;
esac

echo "Installing Ansible for Debian $DEBIAN_VERSION using Ubuntu $UBUNTU_CODENAME PPA..."

# Install gpg if not available
if ! command -v gpg &> /dev/null; then
    echo "Installing gpg..."
    sudo apt update
    sudo apt install -y gpg
fi

wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt update && sudo apt install -y ansible



