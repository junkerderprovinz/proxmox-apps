#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/parleyport

APP="ParleyPort"
var_tags="${var_tags:-network;relay}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
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

  if [[ ! -d /opt/parleyport ]]; then
    msg_error "No ParleyPort Installation Found!"
    exit
  fi

  if check_for_gh_release "parleyport" "junkerderprovinz/parleyport"; then
    msg_info "Stopping ParleyPort"
    systemctl stop parleyport
    msg_ok "Stopped ParleyPort"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "parleyport" "junkerderprovinz/parleyport" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/parleyport/go.mod | awk '{print $2}')" setup_go

    msg_info "Building ParleyPort"
    cd /opt/parleyport
    CGO_ENABLED=0 $STD go build -ldflags "-s -w -X github.com/junkerderprovinz/parleyport/internal/buildinfo.Version=v$(cat ~/.parleyport)" -o /opt/parleyport/parleyport ./cmd/parleyport
    $STD go clean -cache -modcache
    msg_ok "Built ParleyPort"

    msg_info "Starting ParleyPort"
    systemctl start parleyport
    msg_ok "Started ParleyPort"
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
echo -e "${GATEWAY}${BGN}http://${IP}:8760/health${CL}"
