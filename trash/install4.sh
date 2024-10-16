#!/bin/bash

SCRIPT_NAME="ngrok-run"
TARGET_PATH="/usr/local/bin"
CONFIG_DIR="/etc/ngrok-run"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
SOURCE_DIR="$(pwd)"

# Fungsi untuk menambahkan atau memperbarui authtoken di config.yaml
set_ngrok_token() {
    echo "Please enter your Ngrok Authtoken:"
    read -r NGROK_AUTHTOKEN

    if [ -z "$NGROK_AUTHTOKEN" ]; then
        echo "No Authtoken provided. Exiting."
        exit 1
    fi

    # Update authtoken di config.yaml
    if grep -q "authtoken:" "$CONFIG_FILE"; then
        sed -i "s/\(authtoken:\s*\).*/\1${NGROK_AUTHTOKEN}/" "$CONFIG_FILE"
    else
        echo "agent:\n  authtoken: ${NGROK_AUTHTOKEN}" >> "$CONFIG_FILE"
    fi
    echo "Ngrok Authtoken has been set to: $NGROK_AUTHTOKEN"
}

# Fungsi untuk menambahkan atau memperbarui hostname di config.yaml
set_ngrok_hostname() {
    echo "Please enter your Ngrok hostname (or leave blank to skip):"
    read -r NGROK_HOSTNAME

    if [ -n "$NGROK_HOSTNAME" ]; then
        # Update hostname di config.yaml untuk tunnel HTTP dan HTTP-8081
        for tunnel in "http" "http-8081"; do
            if grep -q "^  $tunnel:" "$CONFIG_FILE"; then
                sed -i "/^  $tunnel:/,/^  /s/\(hostname: \).*/\1${NGROK_HOSTNAME}/" "$CONFIG_FILE"
            else
                echo "  $tunnel:\n    proto: http\n    addr: ${tunnel##*-}\n    hostname: ${NGROK_HOSTNAME}" >> "$CONFIG_FILE"
            fi
        done
        echo "Ngrok hostname has been set to: $NGROK_HOSTNAME"
    else
        echo "No hostname provided. Skipping hostname update."
    fi
}

# Fungsi untuk menginstal skrip
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

# Fungsi untuk menyalin file ke direktori konfigurasi
copy_files_to_config_dir() {
    echo "Copying files to $CONFIG_DIR..."

    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Creating $CONFIG_DIR..."
        sudo mkdir -p "$CONFIG_DIR"
    fi

    sudo cp -r "$SOURCE_DIR"/* "$CONFIG_DIR/"

    echo "All files have been copied to $CONFIG_DIR."
}

# Setup
# Membuat config.yaml jika belum ada
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
