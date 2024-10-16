#!/bin/bash

SCRIPT_NAME="ngrok-run"
TARGET_PATH="/usr/local/bin"
CONFIG_DIR="/etc/ngrok-run"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
SOURCE_DIR="$(pwd)"

set_ngrok_token() {
    echo "Please enter your Ngrok Authtoken:"
    read -r NGROK_AUTHTOKEN

    if [ -z "$NGROK_AUTHTOKEN" ]; then
        echo "No Authtoken provided. Exiting."
        exit 1
    fi

    # Update the authtoken in config.yaml
    sed -i "/^agent:/,/^tunnels:/s/\(\s*authtoken:\s*\).*/\1${NGROK_AUTHTOKEN}/" "$CONFIG_FILE"
    echo "Ngrok Authtoken has been set to: $NGROK_AUTHTOKEN"
}

set_ngrok_hostname() {
    echo "Please enter your Ngrok hostname (or leave blank to skip):"
    read -r NGROK_HOSTNAME

    if [ -z "$NGROK_HOSTNAME" ]; then
        echo "No hostname provided. Exiting."
        exit 1
    fi

    # Update the hostname in config.yaml for HTTP and other tunnels
    sed -i "/^tunnels:/,/^$/s/\(\s*hostname: \).*/\1${NGROK_HOSTNAME}/g" "$CONFIG_FILE"
    echo "Ngrok hostname has been set to: $NGROK_HOSTNAME"
}

install_script() {
    echo "Installing $SCRIPT_NAME to $TARGET_PATH..."
    
    if [ -f "$TARGET_PATH/$SCRIPT_NAME" ]; then
        echo "$SCRIPT_NAME already exists at $TARGET_PATH, replacing it."
        sudo rm "$TARGET_PATH/$SCRIPT_NAME"
    fi

    sudo cp "$SCRIPT_NAME" "$TARGET_PATH/$SCRIPT_NAME"
    
    sudo chmod +x "$TARGET_PATH/$SCRIPT_NAME"

    echo "$SCRIPT_NAME has been installed and is now executable globally."
}

copy_files_to_config_dir() {
    echo "Copying files to $CONFIG_DIR..."

    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Creating $CONFIG_DIR..."
        sudo mkdir -p "$CONFIG_DIR"
    fi

    sudo cp -r "$SOURCE_DIR"/* "$CONFIG_DIR/"

    echo "All files have been copied to $CONFIG_DIR."
}

# setup
# Create config.yaml if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating config.yaml..."
    sudo mkdir -p "$CONFIG_DIR"
    sudo tee "$CONFIG_FILE" > /dev/null <<EOL
version: "3"
agent:
  authtoken: ""
tunnels:
  ssh:
    proto: tcp
    addr: 22
  http:
    proto: http
    addr: 80
    hostname: ""
  http-8081:
    proto: http
    addr: 8081
    hostname: ""
EOL
fi

set_ngrok_token
set_ngrok_hostname
install_script
copy_files_to_config_dir

echo "Setup completed successfully!"
sleep 2
