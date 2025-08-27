#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/PedroBuffon/mediarr/refs/heads/main/proxmox/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://sonarr.tv/

APP="Mediarr"
var_tags="${var_tags:-arr}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-6144}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage

    if [[ ! -d /var/lib/sonarr/ ]]; then
        msg_error "No Sonarr Installation Found!"
        exit
    fi

    RELEASE_SONARR=$(curl -fsSL https://api.github.com/repos/Sonarr/Sonarr/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    if [[ ! -f ~/.sonarr ]] || [[ "$RELEASE_SONARR" != "$(cat ~/.sonarr 2>/dev/null)" ]]; then
        rm -rf /opt/Sonarr
        fetch_and_deploy_gh_release "Sonarr" "Sonarr/Sonarr" "prebuild" "latest" "/opt/Sonarr" "Sonarr.master*linux-core-x64.tar.gz"
        chmod 775 /opt/Sonarr
        msg_ok "Updated successfully"
    else
        msg_ok "No update required. Sonarr is already at v${RELEASE_SONARR}"
    fi

    if [[ ! -d /var/lib/radarr/ ]]; then
        msg_error "No Radarr Installation Found!"
        exit
    fi

    RELEASE_RADARR=$(curl -fsSL https://api.github.com/repos/Radarr/Radarr/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    if [[ ! -f ~/.radarr ]] || [[ "$RELEASE_RADARR" != "$(cat ~/.radarr 2>/dev/null)" ]]; then
        rm -rf /opt/Radarr
        fetch_and_deploy_gh_release "Radarr" "Radarr/Radarr" "prebuild" "latest" "/opt/Radarr" "Radarr.master*linux-core-x64.tar.gz"
        chmod 775 /opt/Radarr
        msg_ok "Updated successfully"
    else
        msg_ok "No update required. Radarr is already at v${RELEASE_RADARR}"
    fi

    if [[ ! -d /var/lib/prowlarr/ ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    RELEASE_PROWLARR=$(curl -fsSL https://api.github.com/repos/Prowlarr/Prowlarr/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
    if [[ "${RELEASE_PROWLARR}" != "$(cat ~/.prowlarr 2>/dev/null)" ]] || [[ ! -f ~/.prowlarr ]]; then
        rm -rf /opt/Prowlarr
        fetch_and_deploy_gh_release "prowlarr" "Prowlarr/Prowlarr" "prebuild" "latest" "/opt/Prowlarr" "Prowlarr.master*linux-core-x64.tar.gz"
        chmod 775 /opt/Prowlarr
        msg_ok "Successfully updated"
    else
        msg_ok "No update required. ${APP} is already at ${RELEASE_PROWLARR}"
    fi

    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access to services using the following URLs:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8989${CL}"