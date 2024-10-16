if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or log in as root."
    exit 1
fi

sudo rm -rf /etc/ngrok-run/
sudo rm -rf /usr/local/bin/ngrok-run