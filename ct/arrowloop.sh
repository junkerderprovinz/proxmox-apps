#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/arrowloop

APP="ArrowLoop"
var_tags="${var_tags:-sync;backup}"
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

  if [[ ! -d /opt/arrowloop ]]; then
    msg_error "No ArrowLoop Installation Found!"
    exit
  fi

  if check_for_gh_release "arrowloop" "junkerderprovinz/arrowloop"; then
    NODE_VERSION="24" setup_nodejs

    msg_info "Stopping ArrowLoop"
    systemctl stop arrowloop
    msg_ok "Stopped ArrowLoop"

    CLEAN_INSTALL=1 CLEAN_INSTALL_KEEP="config" fetch_and_deploy_gh_release "arrowloop" "junkerderprovinz/arrowloop" "tarball"
    GO_VERSION="$(grep -m1 '^go ' /opt/arrowloop/go.mod | awk '{print $2}')" setup_go

    msg_info "Building ArrowLoop"
    cd /opt/arrowloop
    $STD npm --prefix web ci --no-audit --no-fund
    $STD npm --prefix web run build
    CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w -X github.com/junkerderprovinz/arrowloop/internal/boot.Version=v$(cat ~/.arrowloop)" -o /opt/arrowloop/arrowloop ./cmd/arrowloop
    $STD go clean -cache -modcache
    rm -rf /opt/arrowloop/web/node_modules ~/.npm
    msg_ok "Built ArrowLoop"

    msg_info "Starting ArrowLoop"
    systemctl start arrowloop
    msg_ok "Started ArrowLoop"
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
echo -e "${GATEWAY}${BGN}http://${IP}:8422${CL}"
