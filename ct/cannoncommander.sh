#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/cannoncommander

APP="CannonCommander"
var_tags="${var_tags:-files;file-manager}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"
var_fuse="${var_fuse:-yes}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/cannoncommander ]]; then
    msg_error "No CannonCommander Installation Found!"
    exit
  fi

  if check_for_gh_release "cannoncommander" "junkerderprovinz/cannoncommander"; then
    NODE_VERSION="24" setup_nodejs

    msg_info "Stopping CannonCommander"
    systemctl stop cannoncommander
    msg_ok "Stopped CannonCommander"

    CLEAN_INSTALL=1 CLEAN_INSTALL_KEEP="config" fetch_and_deploy_gh_release "cannoncommander" "junkerderprovinz/cannoncommander" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/cannoncommander/backend/go.mod | awk '{print $2}')" setup_go

    msg_info "Building CannonCommander"
    cd /opt/cannoncommander/frontend
    $STD npm ci --no-audit --no-fund
    $STD npm run build:docker
    mkdir -p /opt/cannoncommander/backend/internal/web
    cp -r /opt/cannoncommander/frontend/dist /opt/cannoncommander/backend/internal/web/dist
    cd /opt/cannoncommander/backend
    $STD go run ./scripts/setup-gofitz-cgo
    CGO_ENABLED=1 $STD go build -tags mupdf -ldflags "-w -s -X 'github.com/junkerderprovinz/cannoncommander/backend/internal/version.Version=v$(cat ~/.cannoncommander)'" -o /opt/cannoncommander/backend/cannoncommander .
    $STD go clean -cache -modcache
    rm -rf /opt/cannoncommander/frontend/node_modules ~/.npm
    msg_ok "Built CannonCommander"

    msg_info "Starting CannonCommander"
    systemctl start cannoncommander
    msg_ok "Started CannonCommander"
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
echo -e "${GATEWAY}${BGN}http://${IP}${CL}"
