#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/trickwork

APP="TrickWork"
var_tags="${var_tags:-ascii-art;images}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-6}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-yes}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/trickwork ]]; then
    msg_error "No TrickWork Installation Found!"
    exit
  fi

  if check_for_gh_release "trickwork" "junkerderprovinz/trickwork"; then
    NODE_VERSION="24" setup_nodejs

    msg_info "Stopping TrickWork"
    systemctl stop trickwork
    msg_ok "Stopped TrickWork"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "trickwork" "junkerderprovinz/trickwork" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/trickwork/go.mod | awk '{print $2}')" setup_go

    msg_info "Building TrickWork"
    cd /opt/trickwork
    $STD npm ci --no-audit --no-fund
    $STD npm run build
    cp -r /opt/trickwork/ui/dist /opt/trickwork/webembed/dist
    CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w" -o /opt/trickwork/trickwork-server ./container
    $STD go clean -cache -modcache
    rm -rf /opt/trickwork/node_modules ~/.npm
    msg_ok "Built TrickWork"

    msg_info "Starting TrickWork"
    systemctl start trickwork
    msg_ok "Started TrickWork"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:3210${CL}"
