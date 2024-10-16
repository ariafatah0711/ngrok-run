#!/bin/bash

SCRIPT_NAME="ngrok-run"
TARGET_PATH="/usr/local/bin"
CONFIG_DIR="/etc/ngrok-run"
SOURCE_DIR="$(pwd)"

add_profile_to_bashrc() {
    if [ ! -f ~/.profile.sh ]; then
        echo "~/.profile.sh does not exist. Creating it..."
        touch ~/.profile.sh
        echo "#!/bin/bash" > ~/.profile.sh
        echo "export NGROK_AUTHTOKEN='<token>'" >> ~/.profile.sh
        echo "export NGROK_HOSTNAME='<domain>'" >> ~/.profile.sh
        echo "~/.profile.sh has been created."
    else
        echo "~/.profile.sh already exists."
    fi

    if ! grep -Fxq "source ~/.profile.sh" ~/.bashrc; then
        echo "Adding source ~/.profile.sh to ~/.bashrc"
        echo "source ~/.profile.sh" >> ~/.bashrc
    else
        echo "~/.profile.sh is already sourced in ~/.bashrc"
    fi
}

set_ngrok_token() {
    if [ -z "$NGROK_AUTHTOKEN" ]; then
        echo "Please enter your Ngrok Authtoken:"
        read -r NGROK_AUTHTOKEN

        echo "export NGROK_AUTHTOKEN=\"$NGROK_AUTHTOKEN\"" >> ~/.profile.sh
        export NGROK_AUTHTOKEN="$NGROK_AUTHTOKEN"
        echo "Ngrok Authtoken has been set and added to ~/.profile.sh"
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
                sed -i "/export NGROK_AUTHTOKEN=/c\export NGROK_AUTHTOKEN=\"$new_token\"" ~/.profile.sh
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

        echo "export NGROK_HOSTNAME=\"$NGROK_HOSTNAME\"" >> ~/.profile.sh
        export NGROK_HOSTNAME="$NGROK_HOSTNAME"
        echo "Ngrok hostname has been set and added to ~/.profile.sh"
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
                sed -i "/export NGROK_HOSTNAME=/c\export NGROK_HOSTNAME=\"$new_hostname\"" ~/.profile.sh
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
add_profile_to_bashrc

set_ngrok_token
set_ngrok_hostname
install_script
copy_files_to_config_dir

echo "Setup completed successfully!"
sleep 2

source ~/.profile.sh