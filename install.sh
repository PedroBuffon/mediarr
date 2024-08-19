#!/bin/bash

# Determine if Docker is installed if not installed use the default installation method from https://docs.docker.com/compose/install/

echo "THIS SCRIPT IS STILL IN DEVELOPMENT, DONT USE IT IF YOU DONT KNOW WHAT YOURE DOING"

if command -v docker-compose &> /dev/null; then
    compose_cmd="docker-compose"
elif docker compose version &> /dev/null; then
    compose_cmd="docker compose"
else
    echo "Docker Compose is not installed."
    # Ask if the user wants to install docker
    read -p "Do you want to install docker? (y/n):" install_docker
    if [[ "$install_docker" =~ ^[Yy]$ ]]; then
        # Install Docker
        echo "Installing Docker..."
        curl -sSL https://get.docker.com/ | CHANNEL=stable sh

        # Enable and start Docker service
        echo "Enabling and starting Docker service..."
        sudo systemctl enable --now docker
    fi
fi

# Check if the script is being run as root
if [ `whoami` != 'root' ]; then
    read -p "Do you want to be added to the docker group? (y/n): " add_to_group
    if [[ "$add_to_group" =~ ^[Yy]$ ]]; then
        sudo usermod -aG docker "$USER"
        echo "You have been added to the docker group."
        echo  "Please log out and back in for the changes to take effect and run the script again."
        exit 1
    fi
fi

# Prompt for a directory to clone the repository
default_directory="/opt/docker"
read -p "Enter the directory where you want to clone mediarr (default: $default_directory): " directory
directory=${directory:-$default_directory}

# Clone the repository
echo "Cloning the mediarr repository..."
git clone https://github.com/PedroBuffon/mediarr.git "$directory/mediarr"

# Navigate to the repository directory
cd "$directory/mediarr" || { echo "Failed to navigate to the repository directory"; exit 1; }

# Update the INSTALLDIR in the .env file if the directory is not the default
if [ "$directory" != "$default_directory" ]; then
    echo "Updating INSTALLDIR in the .env file..."
    sed -i "s|^INSTALLDIR=.*|INSTALLDIR=$directory|" .env
fi

# Ask if the user wants to change the UID and GID for the mediarr stack
read -p "Do you want to change the UID and GID for the mediarr stack? (default: 1000) (y/n): " change_uid_gid
if [[ "$change_uid_gid" =~ ^[Yy]$ ]]; then
    read -p "Enter the UID for mediarr (default: 1000): " uid
    uid=${uid:-1000}
    read -p "Enter the GID for mediarr (default: 1000): " gid
    gid=${gid:-1000}
    
    echo "Updating UID and GID in the .env file..."
    sed -i "s/^PUID=.*/PUID=$uid/" .env
    sed -i "s/^PGID=.*/PGID=$gid/" .env
fi

# Pull Docker Compose images
echo "Pulling Docker Compose images..."
sudo $compose_cmd pull

# Ask if the user if it wants to start the docker stack
read -p "Do you want to start the docker stack? " start_stack
if [[ "$start_stack" =~ ^[Yy]$ ]]; then
    sudo $compose_cmd up -d
    echo "Stack started"
    clear

fi

# Display the ports to the user
echo "Setup completed."
echo "Services will be available at the following ports:"
echo "Sonarr: 8989"
echo "Radarr: 7878"
echo "Prowlarr: 9696"
echo "qBittorrent: 2081"
echo "Plex: 32400"
echo "Tautulli: 8181"
echo "Ports can be modified in the docker-compose.yml file"