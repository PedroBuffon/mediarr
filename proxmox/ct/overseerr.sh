#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://overseerr.dev/

APP="Overseerr"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
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
  check_container_resources
  if [[ ! -d /opt/overseerr ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  
  RELEASE=$(curl -fsSL https://api.github.com/repos/sct/overseerr/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f ~/.overseerr ]] || [[ "${RELEASE}" != "$(cat ~/.overseerr)" ]]; then
    msg_info "Stopping ${APP} service"
    systemctl stop overseerr
    msg_ok "Service stopped"

    msg_info "Creating backup"
    mv /opt/overseerr/config /opt/config_backup
    msg_ok "Backup created"

    fetch_and_deploy_gh_release "overseerr" "sct/overseerr" "tarball"
    rm -rf /opt/overseerr/config

    msg_info "Configuring ${APP} (Patience)"
    cd /opt/overseerr
    $STD yarn install
    $STD yarn build
    mv /opt/config_backup /opt/overseerr/config
    msg_ok "Configured ${APP}"

    msg_info "Starting ${APP} service"
    systemctl start overseerr
    msg_ok "Started ${APP} service"

    msg_ok "Updated successfully!"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5055${CL}"
