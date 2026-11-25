#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/trickwork

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

NODE_VERSION="24" setup_nodejs

fetch_and_deploy_gh_release "trickwork" "junkerderprovinz/trickwork" "tarball"
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

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/trickwork.service
[Unit]
Description=TrickWork
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/trickwork
Environment=PORT=3210
ExecStart=/opt/trickwork/trickwork-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now trickwork
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
