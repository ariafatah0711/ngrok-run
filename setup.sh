#!/bin/bash

SCRIPT_NAME="ngrok-run"
TARGET_PATH="/usr/local/bin"

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

install_script
