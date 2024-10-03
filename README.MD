# Self-Hosted Media Server

This is currently a work in progress. Please refer to the [Servarr Docker Setup](https://wiki.servarr.com/docker-guide) for more details on installing the stack.<br>
For installing docker you can run the bellow code that will install docker by itself or you can refer to [Oficial Docker Setup](https://docs.docker.com/engine/install)

## Basic Installation

You can run the script using the bellow methods.

| Method    | Command                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/PedroBuffon/mediarr/main/install.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/PedroBuffon/mediarr/main/install.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/PedroBuffon/mediarr/main/install.sh)"` |

## Data Directory

### Folder Mapping

It's good practise to give all containers the same access to the same root directory or share. This is why all containers in the compose file have the bind volume mount ```/data:/data```. It makes everything easier, plus passing in two volumes such as the commonly suggested /tv, /movies, and /downloads makes them look like two different file systems, even if they are a single file system outside the container. See my current setup below.

```text
data
├── torrents
│   ├── animes
│   ├── movies 
│   └── series
└── media
    ├── animes
    ├── movies
    ├── series

## User Permissions
Using bind mounts (path/to/config:/config) may lead to permissions conflicts between the host operating system and the container.
To avoid this problem, we specify the user ID (PUID) and group ID (PGID) to use within the container.
This will have your user permission to read and write configuration files, etc.

In this compose file I use PUID=1000 and PGID=1000, as that is generally the default ID's in most Linux systems, but depending on your setup you may need to chage this.

PUID=1000
PGID=1000

In the example output above, I would need to edit the .env with PGID=1000.
```

## .env file

The following is my .env file containing some variables that are used on some or all containers

```text
PUID=1000
PGID=1000
TZ=America/Sao_Paulo

#Falresolver
LOG_LEVEL=info

#qBittorrent
WEBUI_PORT=2081

#Plex
PLEXVERSION=docker

#Themes
TP_THEME=dracula
THEMESONARR=ghcr.io/themepark-dev/theme.park:sonarr
THEMERADARR=ghcr.io/themepark-dev/theme.park:radarr
THEMEPROWLARR=ghcr.io/themepark-dev/theme.park:prowlarr
```

Change according of use case

## Network

Very optional, only use this if you want to change the network ip inside the docker stack. Not really needed, i just added to organize my docker install

You can see at the end of the compose file that there is a config block called networks, see below:

```yml
networks:
  default:
    name: mediarr
    enable_ipv6: true
    ipam:
      config:
        - subnet: 192.168.10.0/24 #IPV4 NETWORK
        - subnet: 2001:db8:2::/64 #IPV6 NETWORK
```

This configuration creates a separate network on docker only for the containers in the docker compose so they can "Talk" to each other.

## Label

You can see on the compose file some of the containers have a label.

```yml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```

As i use [Watchtowerr](https://github.com/containrrr/watchtower) for automating Docker container base image updates, i encountered some corruption in files when updating docker images while sonarr or qbit were copying files, so the label makes watchtowerr only notifying the user that there is an update and not updating it automatically.

### Handling the `.Trash-id` Folder using qBittorrent Version 5.0

If you've recently upgraded qBittorrent to version 5.0 and noticed a folder called `.Trash-id` appearing on your drive, you're not alone.  
This behavior is caused by the way Sonarr/Radarr and Completed Download Handling work in conjunction with version 5.0.

### Why is the `.Trash-id` Folder Appearing?

In qBittorrent version 5.0, when torrents are marked for deletion and you have **Completed Download Handling** turned on in Sonarr/Radarr,  
the downloaded torrents are not immediately removed. Instead, they are copied to a `.Trash` folder.  
This folder holds the "deleted" torrents, which is why you see the `.Trash-id` on your drive.

### How to Change This Behavior

If you're running qBittorrent version 5.0 and want to adjust how torrents are handled when removed, follow these steps:

1. Go to the **Advanced** settings of your torrent client.  
2. Navigate to **Torrent content removing mode**.  
3. Change the behavior to suit your preference.

By changing the **Torrent content removing mode**, you can decide how your torrent client handles deleted torrents,  
preventing them from being moved to the `.Trash-id` folder.

This will help keep your drive clean and avoid unnecessary storage usage.
