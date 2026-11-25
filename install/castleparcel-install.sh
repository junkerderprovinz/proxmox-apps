#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/castleparcel

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

NODE_VERSION="24" setup_nodejs

fetch_and_deploy_gh_release "castleparcel" "junkerderprovinz/castleparcel" "tarball"
GO_VERSION="$(grep -m1 '^go ' /opt/castleparcel/server-go/go.mod | awk '{print $2}')" setup_go

msg_info "Building CastleParcel"
cd /opt/castleparcel
$STD npm ci --no-audit --no-fund
$STD npm run build:spa
cd /opt/castleparcel/server-go
CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w" -o /opt/castleparcel/castleparcel .
$STD go clean -cache -modcache
rm -rf /opt/castleparcel/node_modules ~/.npm
mkdir -p /opt/castleparcel/data /opt/castleparcel/config
msg_ok "Built CastleParcel"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/castleparcel.service
[Unit]
Description=CastleParcel
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/castleparcel
Environment=PORT=3000
Environment=DATA_DIR=/opt/castleparcel/data
Environment=CONFIG_DIR=/opt/castleparcel/config
ExecStart=/opt/castleparcel/castleparcel
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now castleparcel
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
