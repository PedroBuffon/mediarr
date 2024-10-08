#!/bin/bash

echo "THIS SCRIPT IS STILL IN DEVELOPMENT. DON'T USE IT IF YOU DON'T KNOW WHAT YOU'RE DOING"

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run as root. Please use sudo."
    exit 1
fi

# Update package list
if apt-get update; then
    echo "Package list updated successfully."
else
    echo "Failed to update package list."
    exit 1
fi

# Checks if curl is installed
if ! command -v curl >/dev/null 2>&1; then
    read -p "Curl is required to continue, do you want to install it? (y/n): " install_curl
    if [ "$install_curl" = "y" ] || [ "$install_curl" = "Y" ]; then
        apt-get install curl -y
        if ! command -v curl >/dev/null 2>&1; then
            echo "Curl installation failed. Please check the installation process."
            exit 1
        fi
    else
        echo "Curl is required to continue. Exiting."
        exit 1
    fi
else
    echo "Curl is installed. Continuing."
fi

# Checks if git is installed
if ! command -v git >/dev/null 2>&1; then
    read -p "Git is required to continue, do you want to install it? (y/n): " install_git
    if [ "$install_git" = "y" ] || [ "$install_git" = "Y" ]; then
        apt-get install git -y
        if ! command -v git >/dev/null 2>&1; then
            echo "Git installation failed. Please check the installation process."
            exit 1
        fi
    else
        echo "Git is required to continue. Exiting."
        exit 1
    fi
else
    echo "Git is installed. Continuing."
fi

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    curl -sSL https://get.docker.com/ | CHANNEL=stable sh

    # Enable and start Docker service
    echo "Enabling and starting Docker service..."
    systemctl enable --now docker

    read -p "Do you want to be added to the docker group? (y/n): " add_to_group
    if [ "$add_to_group" = "y" ] || [ "$add_to_group" = "Y" ]; then
        usermod -aG docker "$SUDO_USER"
        echo "You have been added to the docker group."
        echo "Please log out and back in for the changes to take effect, and run the script again."
        exit 1
    fi
}

# Check for Docker Compose command
if command -v docker-compose >/dev/null 2>&1; then
    compose_cmd="docker-compose"
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    compose_cmd="docker compose"
else
    echo "Docker Compose is not installed."
    # Ask if the user wants to install Docker
    read -p "Do you want to install Docker? (y/n): " install_docker_choice
    if [ "$install_docker_choice" = "y" ] || [ "$install_docker_choice" = "Y" ]; then
        install_docker
        if command -v docker-compose >/dev/null 2>&1; then
            compose_cmd="docker-compose"
        elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
            compose_cmd="docker compose"
        else
            echo "Docker Compose installation failed. Please check the installation process."
            exit 1
        fi
    else
        echo "Docker is required to continue. Exiting."
        exit 1
    fi
fi

# Prompt for a directory to clone the repository
default_directory="/opt/docker"
read -p "Enter the FULL DIRECTORY PATH where you want to clone mediarr, THIS IS WERE CONFIG FILES WILL BE SAVED (default: $default_directory): " directory
directory=${directory%/}  # Remove trailing slash if present
directory=${directory:-$default_directory}

# Clone the repository
echo "Cloning the mediarr repository..."
if ! git clone https://github.com/PedroBuffon/mediarr.git "$directory/mediarr"; then
    echo "Failed to clone the repository."
    exit 1
fi

# Navigate to the repository directory
cd "$directory/mediarr" || { echo "Failed to navigate to the repository directory"; exit 1; }

# Update the INSTALLDIR in the .env file if the directory is not the default
# if [ "$directory" != "$default_directory" ]; then
#     echo "Updating INSTALLDIR in the .env file..."
#     sed -i "s|^INSTALLDIR=.*|INSTALLDIR=$directory|" .env
# fi

# Ask if the user wants to change the UID and GID for the mediarr stack
read -p "Do you want to change the UID and GID for the mediarr stack? (default: 1000) (y/n): " change_uid_gid
if [ "$change_uid_gid" = "y" ] || [ "$change_uid_gid" = "Y" ]; then
    read -p "Enter the UID for mediarr (default: 1000): " uid
    uid=${uid:-1000}

    # Check if the UID exists
    if ! getent passwd "$uid" > /dev/null; then
        echo "Error: UID $uid does not exist on this system."
        exit 1
    fi

    read -p "Enter the GID for mediarr (default: 1000): " gid
    gid=${gid:-1000}

    # Check if the GID exists
    if ! getent group "$gid" > /dev/null; then
        echo "Error: GID $gid does not exist on this system."
        exit 1
    fi

    echo "Updating UID and GID in the .env file..."
    sed -i "s/^PUID=.*/PUID=$uid/" .env
    sed -i "s/^PGID=.*/PGID=$gid/" .env
    chown -R $uid:$gid $directory/mediarr
else
    chown -R 1000:1000 $directory/mediarr
fi


# Ask if the user wants to change the TZ for the mediarr stack
read -p "Do you want to change the timezone for the mediarr stack? (default: America/Sao_Paulo) (y/n): " change_tz
if [ "$change_tz" = "y" ] || [ "$change_tz" = "Y" ]; then
    read -p "Enter the TZ for mediarr (default: America/Sao_Paulo): " tz
    tz=${tz:-America/Sao_Paulo}

    echo "Updating TZ in the .env file..."
    sed -i "s/^TZ=.*/TZ=$tz/" .env
fi

# Ask if the user wants to change the HOSTDATA and CONTAINERDATA for the mediarr stack
read -p "Do you want to change the HOSTDATA and CONTAINERDATA for the mediarr stack? This is where your media files are on the Host and Container (default: /data) (y/n): " change_data
if [ "$change_data" = "y" ] || [ "$change_data" = "Y" ]; then
    read -p "Enter the HOSTDATA for mediarr (default: /data): " hostdata
    hostdata=${hostdata:-/data}
    read -p "Enter the CONTAINERDATA for mediarr (default: /data): " containerdata
    containerdata=${containerdata:-/data}

    echo "Updating HOSTDATA and CONTAINERDATA in the .env file..."
    sed -i "s|^HOSTDATA=.*|HOSTDATA=$hostdata|" .env
    sed -i "s|^CONTAINERDATA=.*|CONTAINERDATA=$containerdata|" .env
fi

# Pull Docker Compose images
echo "Pulling Docker Compose images..."
$compose_cmd pull

# Ask if the user wants to start the Docker stack
read -p "Do you want to start the Docker stack? (y/n): " start_stack
if [ "$start_stack" = "y" ] || [ "$start_stack" = "Y" ]; then
    $compose_cmd up -d
    echo "Stack started"
    clear
fi

# Get the local IP address
local_ip=$(hostname -I | awk '{print $1}')

# Display the ports to the user
echo "Setup completed."
echo "Services will be available at the following ports:"
echo "Sonarr:      $local_ip:8989"
echo "Radarr:      $local_ip:7878"
echo "Prowlarr:    $local_ip:9696"
echo "qBittorrent: $local_ip:2081"
echo "Plex:        $local_ip:32400"
echo "Tautulli:    $local_ip:8181"
echo "Ports can be modified in the docker-compose.yml file"