#!/bin/bash

SCRIPT_NAME="ngrok-run"
TARGET_PATH="/usr/local/bin"
CONFIG_DIR="/etc/ngrok-run"
SOURCE_DIR="$(pwd)"

update_bashrc() {
    echo "Updating ~/.bashrc..."
    source ~/.bashrc
}

set_ngrok_token() {
    if [ -z "$NGROK_AUTHTOKEN" ]; then
        echo "Please enter your Ngrok Authtoken:"
        read -r NGROK_AUTHTOKEN

        echo "export NGROK_AUTHTOKEN=\"$NGROK_AUTHTOKEN\"" >> ~/.bashrc
        export NGROK_AUTHTOKEN="$NGROK_AUTHTOKEN"
        echo "Ngrok Authtoken has been set and added to ~/.bashrc"
    else
        echo "Ngrok Authtoken is already set: $NGROK_AUTHTOKEN"
        echo "Do you want to change the Authtoken? (y/n):"
        read -r change_token

        if [[ "$change_token" == "y" ]]; then
            echo "Please enter your new Ngrok Authtoken:"
            read -r new_token

            if [ -z "$new_token" ]; then
                echo "No Authtoken provided. Keeping the old Authtoken: $NGROK_AUTHTOKEN"
            else
                sed -i "/export NGROK_AUTHTOKEN=/c\export NGROK_AUTHTOKEN=\"$new_token\"" ~/.bashrc
                export NGROK_AUTHTOKEN="$new_token"
                echo "Ngrok Authtoken has been updated to: $NGROK_AUTHTOKEN"
            fi
        else
            echo "Keeping the existing Authtoken: $NGROK_AUTHTOKEN"
        fi
    fi
}

set_ngrok_hostname() {
    if [ -z "$NGROK_HOSTNAME" ]; then
        echo "Please enter your Ngrok hostname (or leave blank to skip):"
        read -r NGROK_HOSTNAME

        if [ -z "$NGROK_HOSTNAME" ]; then
            echo "No hostname provided. Exiting."
            exit 1
        fi

        echo "export NGROK_HOSTNAME=\"$NGROK_HOSTNAME\"" >> ~/.bashrc
        export NGROK_HOSTNAME="$NGROK_HOSTNAME"
        echo "Ngrok hostname has been set and added to ~/.bashrc"
    else
        echo "Ngrok hostname is already set: $NGROK_HOSTNAME"
        echo "Do you want to change the hostname? (y/n):"
        read -r change_hostname

        if [[ "$change_hostname" == "y" ]]; then
            echo "Please enter your new Ngrok hostname:"
            read -r new_hostname

            if [ -z "$new_hostname" ]; then
                echo "No hostname provided. Keeping the old hostname: $NGROK_HOSTNAME"
            else
                sed -i "/export NGROK_HOSTNAME=/c\export NGROK_HOSTNAME=\"$new_hostname\"" ~/.bashrc
                export NGROK_HOSTNAME="$new_hostname"
                echo "Ngrok hostname has been updated to: $NGROK_HOSTNAME"
            fi
        else
            echo "Keeping the existing hostname: $NGROK_HOSTNAME"
        fi
    fi
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
set_ngrok_token
set_ngrok_hostname
install_script
copy_files_to_config_dir
update_bashrc

echo "Setup completed successfully!"
