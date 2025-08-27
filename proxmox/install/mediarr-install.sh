#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://radarr.video/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Global Dependencies"
$STD apt-get install -y sqlite3
msg_ok "Installed Global Dependencies"

msg_info "Installing Sonarr v4"
mkdir -p /var/lib/sonarr/
chmod 775 /var/lib/sonarr/
curl -fsSL "https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64" -o "SonarrV4.tar.gz"
tar -xzf SonarrV4.tar.gz
mv Sonarr /opt
rm -rf SonarrV4.tar.gz

msg_ok "Installed Sonarr v4"

msg_info "Creating Sonarr Service"
cat <<EOF >/etc/systemd/system/sonarr.service
[Unit]
Description=Sonarr Daemon
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/var/lib/sonarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now sonarr
msg_ok "Created Sonarr Service"

fetch_and_deploy_gh_release "Radarr" "Radarr/Radarr" "prebuild" "latest" "/opt/Radarr" "Radarr.master*linux-core-x64.tar.gz"

msg_info "Configuring Radarr"
mkdir -p /var/lib/radarr/
chmod 775 /var/lib/radarr/ /opt/Radarr/
msg_ok "Configured Radarr"

msg_info "Creating Radarr Service"
cat <<EOF >/etc/systemd/system/radarr.service
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
UMask=0002
Type=simple
ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now radarr
msg_ok "Created Radarr Service"

fetch_and_deploy_gh_release "prowlarr" "Prowlarr/Prowlarr" "prebuild" "latest" "/opt/Prowlarr" "Prowlarr.master*linux-core-x64.tar.gz"

msg_info "Configuring Prowlarr"
mkdir -p /var/lib/prowlarr/
chmod 775 /var/lib/prowlarr/ /opt/Prowlarr
msg_ok "Configured Prowlarr"

msg_info "Creating Prowlarr Service"
cat <<EOF >/etc/systemd/system/prowlarr.service
[Unit]
Description=Prowlarr Daemon
After=syslog.target network.target

[Service]
UMask=0002
Type=simple
ExecStart=/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now prowlarr
msg_ok "Created Prowlarr Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
