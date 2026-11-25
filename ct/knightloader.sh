#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/knightloader

APP="KnightLoader"
var_tags="${var_tags:-downloads;media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-12}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/knightloader ]]; then
    msg_error "No KnightLoader Installation Found!"
    exit
  fi

  if check_for_gh_release "knightloader" "junkerderprovinz/knightloader"; then
    msg_info "Stopping KnightLoader"
    systemctl stop knightloader
    msg_ok "Stopped KnightLoader"

    CLEAN_INSTALL=1 CLEAN_INSTALL_KEEP="data" fetch_and_deploy_gh_release "knightloader" "junkerderprovinz/knightloader" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/knightloader/go.mod | awk '{print $2}')" setup_go

    msg_info "Building KnightLoader"
    cd /opt/knightloader
    CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w -X github.com/junkerderprovinz/knightloader/internal/buildinfo.Version=v$(cat ~/.knightloader)" -o /opt/knightloader/knightloader-server ./cmd/knightloader
    $STD go clean -cache -modcache
    msg_ok "Built KnightLoader"

    msg_info "Starting KnightLoader"
    systemctl start knightloader
    msg_ok "Started KnightLoader"
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
echo -e "${GATEWAY}${BGN}http://${IP}:8749${CL}"
