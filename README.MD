# Self-Hosted Media Server

This is currently a work in progress. Please refer to the [Servarr Docker Setup](https://wiki.servarr.com/docker-guide) for more details on installing the stack.

## Data Directory
### Folder Mapping
It's good practise to give all containers the same access to the same root directory or share. This is why all containers in the compose file have the bind volume mount ```/data:/data```. It makes everything easier, plus passing in two volumes such as the commonly suggested /tv, /movies, and /downloads makes them look like two different file systems, even if they are a single file system outside the container. See my current setup below. 
```
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
Using bind mounts (path/to/config:/config) may lead to permissions conflicts between the host operating system and the container. To avoid this problem, we specify the user ID (PUID) and group ID (PGID) to use within the container. This will have your user permission to read and write configuration files, etc.

In this compose file I use PUID=1000 and PGID=1000, as that is generally the default ID's in most Linux systems, but depending on your setup you may need to chage this.

```
PUID=1000
PGID=1000
```
In the example output above, I would need to edit the .env with PGID=1000.