#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/castleparcel

APP="CastleParcel"
var_tags="${var_tags:-file-sharing;encryption}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
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

  if [[ ! -d /opt/castleparcel ]]; then
    msg_error "No CastleParcel Installation Found!"
    exit
  fi

  if check_for_gh_release "castleparcel" "junkerderprovinz/castleparcel"; then
    NODE_VERSION="24" setup_nodejs

    msg_info "Stopping CastleParcel"
    systemctl stop castleparcel
    msg_ok "Stopped CastleParcel"

    CLEAN_INSTALL=1 CLEAN_INSTALL_KEEP="data config" fetch_and_deploy_gh_release "castleparcel" "junkerderprovinz/castleparcel" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/castleparcel/server-go/go.mod | awk '{print $2}')" setup_go

    msg_info "Building CastleParcel"
    cd /opt/castleparcel
    $STD npm ci --no-audit --no-fund
    $STD npm run build:spa
    cd /opt/castleparcel/server-go
    CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w" -o /opt/castleparcel/castleparcel .
    $STD go clean -cache -modcache
    rm -rf /opt/castleparcel/node_modules ~/.npm
    msg_ok "Built CastleParcel"

    msg_info "Starting CastleParcel"
    systemctl start castleparcel
    msg_ok "Started CastleParcel"
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
echo -e "${GATEWAY}${BGN}http://${IP}:3000${CL}"
